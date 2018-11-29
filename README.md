# GlusterPV-Provisioner
> Kubernetes Persistent volume Provisioner for GlusterFS. 

A simple shell script in 100 line of bash to watch the Kubernetes API for `Pending` Persistent Volume Claims, then create the wanted volume on the GlusterFS cluster and finally submit the Persistent Volume to Kubernetes. 

This service is made  to run on your external GlusterFS cluster (or single server) but you can embed it in your Docker Gluster's container to enable Auto-PV creation within your Kubernetes cluster. 

### Installation

```
# Run on one of your Gluster server
mkdir -p /srv/scripts
cd /opt/
git clone git@github.com:valentin2105/GlusterPV-Provisioner.git
chmod +x GlusterPV-Provisioner/gluster-pv.sh
cp GlusterPV-Provisioner/gluster-pv.sh /srv/scripts/
cp GlusterPV-Provisioner/gluster-pv.service /etc/systemd/system/

# Edit the script to match your cluster config (IP, kubeconfig Path)
vim /srv/scripts/gluster-pv.sh

# Launch the service
systemctl daemon-reload
service gluster-pv start
journactl -u gluster-pv -f
```

When the service run, simply install a Helm Chart the requiere some PVs, and GlusterPV-Provisioner will create them for you. 

### Configuration

The configuration is in the first lines of the script : 

```
#!/bin/bash                                                                                                        

# a mandatory name to indentify your Gluster server       
glusterName='glusterfs-cluster'   

# the IP where Kubernetes will mount your Gluster volume (for H/A use a shared IP) 
glusterEP='192.168.42.42'         

# the path of all nodes in your Gluster cluster (use just one in a single-node context) 
glusterClusterPath='192.168.42.42:/gluster-pool 192.168.42.43:/gluster-pool'            

# the path of the kubeconfig file 
kubeConfigPath=/root/.kube/config                                                                                  
                                      
```

### Future

I'm currently working to rewrite this in `Golang`, if someone want help, it would be awesome. 
