!SLIDE
## Containers: Puppetserver

* function: Puppet CA and/or compile nodes
* image: `camptocamp/puppetserver`
* autoconfiguration: puppetdb-termini activated if `puppetdb` name resolves

![Puppet](../_images/puppet.png)



!SLIDE
## Containers: R10k


* function: Deploy Puppet code in all Puppet Server containers.

Two options:

* single node:

   - image: `camptocamp/r10k-githook` (with a Git hook)

* cluster of nodes:

   - images: `camptocamp/r10k` (using MCollective) + `camptocamp/r10k-webhook` (webhook to trigger r10k over MCollective)




!SLIDE
## Containers: PuppetDB


* function: PuppetDB (requires a PostgreSQL database)
* image: `camptocamp/puppetdb`
* optionally supports RW/RO databases

![Puppet](../_images/puppet.png)


!SLIDE
## Containers: PuppetCA/MCollective

* function: pilot Puppet CA from outside the stack using MCollective
* image: `camptocamp/mcollectived_puppetca`



!SLIDE
## Containers: Puppetboard

* function: provide a web interface to visualize PuppetDB data and reports
* image: `camptocamp/puppetboard`


!SLIDE
## Containers: Puppet Catalog Diff

* function: compute catalog diffs between Puppet environments/servers and
  visualize the diffs
* images: `camptocamp/puppet-catalog-diff` and
  `camptocamp/puppet-catalog-diff-viewer`
