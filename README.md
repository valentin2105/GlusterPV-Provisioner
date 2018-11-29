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

