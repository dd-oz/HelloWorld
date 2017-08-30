# Hello world app
	Deployed to http://138.68.191.132 (DigitalOcean)
	github repository: 

# Architecture
	Single machine with proxy, wsgi server (Apache) and flask app has been used in this example.
	client (browser) --- Internet ---> { [apache proxy] -> [apache app_server (wsgi)] -> app }
	
	In ideal scenario proxy would be separate from machines hosting apache+app
	In even better scenario, simple DNS RoundRobin could be used to return IP addresses of more than one proxy talking to the same cluster of app servers.
	App servers could use NFS (with flashcache) for centralisation of code repository... or, in the contrary, git or the like, for more controlled, atomic releases.

	Application firewall (WAF) should sit between the Internet and the proxy. Cloudflare or Incapsula could be used for that.
	Packet filter (firewall) should sit between proxy server and the cluster of application servers.
	Application servers should be in separate network (vlan/subnet/network segment) than everything else -- everything that user can access must be sanitised and treated with care.
	Any access from the outside to the inside should be allowed only by use of some sort of VPN tunnel terminated on VPN gateway.
	
	Once single proxy server has been configured, snapshot would be created.
	The same for single application server.
	
# Deployment process would have to:
	- spin new machine of the requested type (be it proxy or app) cloning it from the snapshot (template)
	- upon first boot some sort of first-boot/release script/CM tool makes sure machine is unique and configured
	- only after these automated checks confirming machine is clean, working and sane, it may be added to the cluster - this is especially important in the environments where every time you request new instance, hardware laying underneath may be different one from the another
	- update DNS when necessary
	- update apache proxy settings with IP of the new app cluster member
	
# Virtual machine creation automation
	- while spinning of the "blank" machines and then customising them through the use of Config Management (Puppet/salt/cfengine) would work, it brings very high compatibility risk - newly created machine may use software in different versions than approved so cloning is proposed as alternative
	- for the DigitalOcean used, I would probably use this document as help to automate template releases: https://www.digitalocean.com/community/tutorials/how-to-use-the-api-to-deploy-droplets-from-a-master-snapshot -- it doesn't really matter as while every cloud provider is slightly different, all of them provide similar api
	
# App image automation
	- in our scenario (single machine for everything), apache configuration is flexible enough for machine to server both as a proxy and application server (simply different interface for wsgi apps would have to be used)
	- ...therefore it's OK to release all the configs and restart apache anyway
	
# Monitoring
	- based on the type of the machine, specific processes must run and specific ports must be open
	- error logs would have to be processed - preferably by sec (simple even correlator) or at least fail2ban (fail2ban could forcibly make faulty member to fail off the cluster)
	- standard http connectivity tests
	- memory/cpu use to catch early memory leaks/etc
	- process accounting (pacct) and/or sar could help, too
	- cluster members would have to be exactly the same (apart of couple of config files), so monitoring of software versions, disk use and health (SMART), hardware problems (e.g. ECC issues, overheating), execution time(s), etc
	- SSL certificates and domain names expiry times
	
# QA
	- it would be probably good to be able to force proxies to select specific cluster member, so QA could test all of them
	- should probably have access to the logfiles of app servers
	
