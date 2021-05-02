# Folding@Cloud

PowerShell/AzureCLI scripts to setup a Folding@Home GPU instance in Azure - from [Greg Orzell](https://github.com/gorzell/folding-at-cloud).


## Prerequisites
1. (Not mandatory, but your points per day will be very disappointing if you don't) A [passkey](https://apps.foldingathome.org/getpasskey) from Folding@Home registered to the username and email you plan to use
1. An [Azure account](https://azure.microsoft.com/en-us/free/).
1. Install the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest).
1. Login your Azure account [via the CLI](https://docs.microsoft.com/en-us/cli/azure/authenticate-azure-cli?view=azure-cli-latest).

## Getting Started
1. Update the Folding@Home configuration in [cloud-init.yaml](https://github.com/gorzell/folding-at-cloud/blob/master/cloud-init.yaml).
1. Run `help start-fahazurevm.ps1`
1. Check the current spot prices for GPU-enabled machines - try changing regions to see where the current cheapest ones are.
1. Consider the price difference between the NV6 (nvidia M60 - approx 500k PPD) and the more common NC6 (nvidia K80 - approx 330k PPD).
1. Run `start-fahazurevm.ps1` with any switches you want - default max hourly price is $0.15 (times 730 hours = $109.50/mo), you might be willing to spend more.
1. Wait about 5-10 minutes for all the packages to be installed - `ssh <public_dns> tail -f /var/log/cloud-init-output.log` until you see someting like `Cloud-init v. 19.4-33-gbb4131a2-0ubuntu1~18.04.1 finished at Mon, 06 Apr 2020 20:18:39 +0000. Datasource DataSourceAzure [seed=/var/lib/waagent].  Up 15.44 seconds`
1. Check the Folding@Home logs: `ssh <public_dns> tail -f /var/lib/fahclient/log.txt` or run direct commands by ssh'ing into the machine and accessing the F@H commandline client with `telnet localhost 36330` and typing `help` to see your options.

## Economics of folding on Azure GPU-enabled VMs

[Pricing - Linux Virtual Machines on Azure](https://azure.microsoft.com/en-us/pricing/details/virtual-machines/linux/)

The current pay-as-you-go cost for the Standard_NC6 VM was $0.90-$1.20/hr for the US and large European regions that this VM type is available for, while the Standard_NV6 was $1.15-$1.50. The Promo versions of these machines is somewhat lower ($0.60-$0.80), but still way more expensive than buying and running an RTX 2060 and a cheap PC, even at German residental electric rates (approx 0.30 EUR/kWh).

The spot instances, on the other hand, were available for as little $0.1189/hr (NC6) and $0.1228/hr (NV6), but those prices varied widely. The cheapest NC6 spot price was in northcentralus, while the NV6 was cheaper in southcentralus than the NC6 in that region and the NV6 in northcentralus.

Unfortunately, even the perpetually in-preview rate sheet API does not provide current spot prices.

The NV6 at $0.1228 per hour is a far better deal than the NC6 at $0.1189, because the points per day (PPD) of the NC6 with the nvidia K80 is about 330k, while the NV6 with the M60 is around 500k!

## Folding At Home Configuration

The content: section of the cloud-init.yaml is what the script copies to your VM. The fah-config.xml and cpu-config.xml files are just for reference. If you add or remove XML tags in cloud-init.yaml, watch the indents - YAML is super-picky like that.

The cpu-cloud-init.yaml is what I use for non-GPU VMs - Hetzner seems to have the cheapest, with a 2 vCPU/4 GB VM running under 6 EUR/mo. The ones larger than that are a waste of money for this - the ratio of RAM per CPU is higher on the higher core count VMs, resulting in higher prices per core.

**User:** This can be any unique identifier that you want to use to track your work contribution. [Read more about users](https://foldingathome.org/support/faq/stats-teams-usernames/).

**Team:** The team that you want to associate your work with. The existing identifier is for the `SQLFamily` team. [Read more about teams](https://foldingathome.org/support/faq/stats-teams-usernames/).

**Passkey:** A unique identifier that ties your contributions directly to you (not just those with your username). [Read more about passkeys](https://foldingathome.org/support/faq/points/passkey/).


