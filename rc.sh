yum update
wget https://bootstrap.pypa.io/ez_setup.py -O - | python 
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/e/epel-release-7-2.noarch.rpm
yum install python-pip gcc libffi-devel python-devel libxslt-devel openssl-devel git
pip install python-keystoneclient
pip install python-neutronclient
pip install python-heatclient
pip install python-glanceclient
pip install git+https://github.com/openstack/python-novaclient
pip install git+https://github.com/openstack/python-cinderclient