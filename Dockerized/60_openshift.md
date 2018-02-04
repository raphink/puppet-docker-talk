!SLIDE
## Puppet on Openshift


* in development, currently internal @ Camptocamp
* plans for our migration from Puppet 4 to Puppet 5


![Puppet Openshift Github](../_images/puppet_openshift_github.png)


!SLIDE
## Puppet on Openshift: charts

* 3 Puppet charts currently: Puppetserver, PuppetDB & R10k-webhook

![Puppet Openshift Charts](../_images/puppet_openshift_charts.png)


!SLIDE
## Puppet on Openshift: advantages

Charts take advantage of ImageStreams, ConfigMaps & Secrets (among others)

![OpenShift Puppetserver
templates](../_images/openshift_puppetserver_templates.png)
