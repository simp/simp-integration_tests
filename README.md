[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-integration_tests.svg)](https://travis-ci.org/simp/pupmod-simp-integration_tests) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-6.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-6.*-orange.svg)

#### Table of Contents
<!-- vim-markdown-toc GFM -->

* [Description](#description)
  * [This is a SIMP project](#this-is-a-simp-project)
* [Setup](#setup)
  * [Setup Requirements](#setup-requirements)
    * [SIMP Vagrant boxes](#simp-vagrant-boxes)
  * [Beginning with integration_tests](#beginning-with-integration_tests)
* [Usage](#usage)
  * [Basic usage](#basic-usage)
    * [Preferred](#preferred)
    * [Alternative](#alternative)
    * [Optional settings](#optional-settings)
  * [beaker:suites[default]](#beakersuitesdefault)
  * [beaker:suites[upgrade]](#beakersuitesupgrade)
* [Troubleshooting](#troubleshooting)
  * [Inspecting troubled beaker VMs using  VRDE (RDP)](#inspecting-troubled-beaker-vms-using--vrde-rdp)
* [Development](#development)

<!-- vim-markdown-toc -->

## Description

Automated integration tests for SIMP—using beaker suites from
[`simp-beaker-helpers`][simp-beaker-helpers] and vagrant boxes built by
[`simp-packer`][simp-packer].

### This is a SIMP project

This module is a tests components of the [System Integrity Management
Platform][simp].

If you find any issues, submit them to our [bug tracker][simp-jira].

## Setup

### Setup Requirements

* [VirtualBox][virtualbox]
* [Vagrant][vagrant]
* [SIMP] vagrant box files (`.box` and `.json`), built by
  [simp-packer][simp-packer] and its rake tasks

#### SIMP Vagrant boxes

It is **strongly** recommended to keep the SIMP vagrant box files in
a `vagrant`-consumable directory tree. This will allow vagrant and beaker to
use detect and use the latest (or a specific) build of a particular SIMP
release.

* [simp-packer][simp-packer] has rake tasks to create and populated this directory tree:
* The rake task `rake vagrant:publish:local` will create/populate a local
  directory tree from a `.box` and `.json` file.
* The [simp-packer][simp-packer] rake task `simp:packer:matrix` will also
  create and populate this directory tree as it builds various boxes.


### Beginning with integration_tests

```sh
BEAKER_vagrant_box_tree=$vagrant_boxes_dir \
BEAKER_box__puppet="simpci/server-6.2.0-RC1.el7-CentOS-7.0.x86-64" \
bundle exec rake beaker:suites
```

## Usage


### Basic usage

#### Preferred

```sh
BEAKER_vagrant_box_tree=$PATH_TO_VAGRANT_BOXES_DIRTREE \
BEAKER_box__puppet="simpci/server-6.2.0-RC1.el7-CentOS-7.0.x86-64" \
bundle exec rake beaker:suites
```


#### Alternative
An alternative method, if you only have a vagrant `.box` + `.json` file bu no
directory tree set up:

```sh
BEAKER_box__puppet="$direct_path_to/server-6.2.0-RC1.el7-CentOS-7.0.x86-64.json
bundle exec rake beaker:suites
```


#### Optional settings

You can force an SUT's platform by setting `BEAKER_box_platform__<sut>`:

```sh
BEAKER_box_platform__puppet=el-7-x86_64
```

### beaker:suites[default]

The default test suite currently just contains a smoke test to ensure that
beaker can bring up a vagrant box and run `puppet apply`

Usage:

```
BEAKER_vagrant_box_tree=$vagrant_boxes_dir \
BEAKER_box__puppet="simpci/server-6.2.0-RC1.el7-CentOS-7.0.x86-64" \
bundle exec rake beaker:suites[default]
```

### beaker:suites[upgrade]

The **upgrade** Beaker suite tests upgrading an installation of an older
version of SIMP using a never version's `.iso` and `unpack_dvd`.

Special Requirements:

* a Vagrant `.box` from the _previous_ version of SIMP
* an `.iso` file from the version of SIMP under test

Usage:

```
BEAKER_vagrant_box_tree=$vagrant_boxes_dir \
BEAKER_box__puppet="simpci/server-6.2.0-RC1.el7-CentOS-7.0.x86-64" \
bundle exec rake beaker:suites[default]
```

Options:


## Troubleshooting

### Inspecting troubled beaker VMs using  VRDE (RDP)

* VirtualBox must have the appropriate version of the [VirtualBox Extension Pack][vb-extpack]
* Turn on VRDE :
```sh
vboxmanage list runningvms
### => defaultyml_puppet_1536852168210_13152" {331df311-52c6-4471-b912-f730d8531e0c}
vboxmanage controlvm "defaultyml_puppet_1536852168210_13152" vrde on
vboxmanage controlvm "defaultyml_puppet_1536852168210_13152" vrdeport 5940
```
* Connect to VRDE using a Remote Desktop client


## Development

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).

[simp]:                     https://github.com/NationalSecurityAgency/SIMP
[simp-contrib]:             https://simp.readthedocs.io/en/master/contributors_guide/
[simp-jira]:                https://simp-project.atlassian.net
[simp-beaker-helpers]:      https://github.com/simp/rubygem-simp-beaker-helpers
[simp-beaker-helpers-docs]: https://github.com/simp/rubygem-simp-beaker-helpers/
[simp-packer]:              https://github.com/simp/simp-packer
[vagrant]:                  https://www.vagrantup.com
[virtualbox]:               https://www.virtualbox.org/wiki/Downloads
[vb-extpack]:               https://www.virtualbox.org/wiki/Downloads#VirtualBox5.2.18OracleVMVirtualBoxExtensionPack
