#!/bin/bash

glusterName=glusterfs-cluster
glusterEP=192.168.1.10
glusterNodesNumber=2
glusterNode01Path=192.168.1.10:/gluster-pool
glusterNode02Path=192.168.1.11:/gluster-pool  
kubeConfigPath=/root/.kube/config

while true; do

        check=$(kubectl --kubeconfig $kubeConfigPath get pvc --all-namespaces --no-headers |grep Pending | head -1)

        if [[ "$check" != "" ]]; then

                ns=$(echo "$check" |awk '{print $1}')
                name=$(echo "$check" |awk '{print $2}')
                checkExist=$(gluster volume list |grep "$name")
                volume="$name"

                if [[ "$checkExist" == "" ]]; then

			# Let's fetch PVC infos
                        size=$(kubectl --kubeconfig $kubeConfigPath -n "$ns" get pvc "$name" -o json | jq -r .spec.resources.requests.storage)
                        label=$(kubectl --kubeconfig $kubeConfigPath -n "$ns" get pvc "$name" -o json | jq -r .metadata.labels.identifier)
                        accessMode=$(kubectl --kubeconfig $kubeConfigPath -n "$ns" get pvc "$name" -o json | jq -r '.spec.accessModes[0]')
                        sizeGluster=$(echo "$size" |cut -d 'G' -f1)

			# Let's create the volume
                        echo "Let's create a Gluster volume ($volume) ..."
                        
                        if ! gluster volume create $volume replica $glusterNodesNumber transport tcp  $glusterNode01Path/$volume $glusterNode02Path/$volume
			then
                                echo "Volume creation error !"
                                exit 1
                        fi

                        gluster volume start "$volume"

			# Put Quota on Gluster volume
                        gluster volume quota "$volume" enable
                        gluster volume quota "$volume" limit-usage / "$sizeGluster"GB

# Let's create Kubernetes SVC & PV
cat <<EOF | kubectl --kubeconfig /root/.kube/config apply -f -
apiVersion: v1
kind: Service
metadata:
  name: $glusterName
  namespace: $ns
spec:
  clusterIP: None
  ports:
  - port: 1
    protocol: TCP
    targetPort: 1
  sessionAffinity: None
---
apiVersion: v1
kind: Endpoints
metadata:
  name: $glusterName
  namespace: $ns
subsets:
- addresses:
  - ip: $glusterEP
  ports:
  - port: 1
    protocol: TCP
EOF
cat <<EOF | kubectl --kubeconfig /root/.kube/config create -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: $volume
  labels:
    identifier: $label
spec:
  capacity:
    storage: $size
  accessModes:
    - $accessMode
  claimRef:
      namespace: $ns
      name: $volume
  glusterfs:
    path: $volume
    endpoints: $glusterName
    readOnly: false
EOF
                        echo "$volume of $size is created. "
                        echo ""

                else
                        echo "$volume already exist.... "
                fi
        fi

        sleep 5
done
