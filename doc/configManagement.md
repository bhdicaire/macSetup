# Configuration management


Your user's configuration items are be stored in the ~/userName directory, however it's not a good practice to copy everything to another computer running the latest version of everything.  You will either lose some configurations if you copy before completing the reinstallation or you'll break something writing over the default configuration.  Even worse, you'll not able to identify all the issues right away.

You should use ``backup config``and ``restore config``to manage those items.

<details>
<summary>Homebrew</summary>

[Homebrew](https://github.com/Homebrew/homebrew) is my preferred package manager. The configuration manager identify and stored the following items:
* brew taps --> ./roles/prepareMac/vars/brewTaps.yml
* brew applications --> ./roles/prepareMac/vars/packages.yml, ./roles/deployMac/vars/packages.yml, and ./roles/deployDev/vars/packages.yml
</details>
<summary>Package configurations</summary>

[Homebrew](https://github.com/Homebrew/homebrew) is my preferred package manager. The configuration manager identify and stored the following items:
* brew taps --> ./roles/prepareMac/vars/brewTaps.yml
* brew applications --> ./roles/prepareMac/vars/packages.yml, ./roles/deployMac/vars/packages.yml, and ./roles/deployDev/vars/packages.yml
</details>

## Overview
This repository is meant to store ansible roles for managing the macOS computers in my lab.
└── roles
    ├── common
    ├── deployDev
    ├── deployMac
    └── deployServer

### Inventory
As this repository only contains roles, I have defined *some* variables in ``group_vars/all``. There is no Ansible inventory or any associated group_vars or host_vars.
As you may know, Ansible depend on these things existing in a separate repository or otherwise accesible by these roles when they are NOT executed on the local host.
## Where should I put variables?
All variables should be defined in the specific ``vars/`` folder for the role they're primarily used in. If the variable you're adding can be used in multiple roles — define it in ``roles/common/vars/``.
If the variable can contain a reasonable default value that should work for all possible devices then define that value in ``group_vars/all/defaults.yml``. Those variables will apply to all nodes unless a group_var file exists that is more specific for that node.
If the variable is something that might need to be defined with a value specific to the device in use, then it'll need to be added to your ``group_vars/all/secret.yml``. I prefer defining those variables in my Bash environment and let Ansible inherit them.
````
# ------------------------------------------------------------
# Secret items
# ------------------------------------------------------------

    aws_cli_user: "{{ lookup('env','aws_cli_user') }}"
    aws_cli_group: "{{ lookup('env','aws_cli_group') }}"
    aws_region: "{{ lookup('env','aws_region') }}"
    aws_access_key_id: "{{ lookup('env','aws_access_key_id') }}"
    aws_secret_access_key: "{{ lookup('env','aws_secret_access_key') }}"
```
This separation is important because I have **regular** Macintosh computers,Developper workstations and Mac Mini Server managed with these roles and each device has different configuration needs.
├── group_vars
│   └── all
│       ├── defaults.yml
│       └── secrets.yml
└── roles
    ├── common
    │   └── vars
    │       ├── brewTaps.yml
    │       ├── macAppStoreConfig.yml
    │       ├── packages.yml
    │       └── packagesConfig.yml
    ├── deployDev
    │   └── vars
    │       ├── packages.yml
    │       └── packagesConfig.yml
    ├── deployMac
    │   └── vars
    │       ├── activityMonitor.yml
    │       ├── bbedit.yml
    │       ├── dock.yml
    │       ├── finder.yml
    │       ├── googleChrome.yml
    │       ├── loginItems.yml
    │       ├── msOffice2016.yml
    │       ├── packages.yml
    │       ├── packagesConfig.yml
    │       ├── photos.yml
    │       ├── safari.yml
    │       ├── spotlight.yml
    │       ├── terminal.yml
    │       ├── timeMachine.yml
    │       └── userPreferences.yml
    └── deployServer
        └── vars
            └── loginItems.yml



.


Setting up a local dev environment
==================================

We assume that your SSH key is present and active for passwordless access to
the "ubuntu" shell user on the hosts that ansible will manage.

Step 1: Install ansible
-----------------------

You can use pip::

  pip install ansible

or use the OS package manager::

  yum install ansible

Step 2: Set up secrets repository
---------------------------------

Clone the secrets repository and symlink the ``hosts`` and ``secrets``
directories into place::

  cd $HOME/dev/
  git clone git@..../ceph-ansible-secrets.git

  sudo mv /etc/ansible/hosts /etc/ansible/hosts.default

  sudo ln -s /path/to/ceph-ansible-secrets/ansible/inventory /etc/ansible/hosts
  sudo ln -s /path/to/ceph-ansible-secrets/ansible/secrets /etc/ansible/secrets

Step 3: Clone the main Ceph ansible repo
----------------------------------------

Clone the main Ceph ansible repository::

  git clone git@..../ceph-cm-ansible.git
  cd ceph-cm-ansible

Step 4 (Optional) Modify ``hosts`` files
----------------------------------------
If you have any new hosts on which you'd like to run ansible, or if you're
using separate testing VMs, edit the files in ``/etc/ansible/hosts`` to add
your new (or testing) hosts::

  vi /etc/ansible/hosts/<labname>

If you don't need to test on any new hosts, you can skip this step and just use
``/etc/ansible/hosts`` as-is.

Step 5: Run ``ansible-playbook``
--------------------------------

You can now run ``ansible-playbook``::

  vi myplaybook.yml
  ansible-playbook myplaybook.yml -vv --check --diff

This will print a lot of debugging output to your console.

Adding a new host to ansible
============================

Ansible runs using the "cm" shell account.

Let's say you've created a new VM host using downburst. At this point you
should have a new VM with the "ubuntu" UID present. The problem is that Ansible
uses the "cm" user. In order to get that UID set up:

1. Add your host to the inventory. Look in your lab's ``secrets`` repository,
   in the ``ansible/inventory/`` directory, and add your new node.

2. Run the ``cephlab.yml`` playbook, limited to your new host "mynewhost"::

    ansible-playbook -vv --limit mynewhost cephlab.yml

## Author

Benoît H. Dicaire, http://github.com/BHDicaire, @BHDicaire, BH@Dicaire.com, http://BHDicaire.com/

### About

I help organizations facing difficult strategic decision-making.

I am a freelance security expert and a keynote speaker in French and English. Over the last 25 years, I have led consulting engagements for well-known companies throughout North America.

I'm [available for hire](http://dicaire.com/).  I’d be pleased to discuss your requirements.
