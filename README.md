[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html) [![Build Status](https://travis-ci.org/simp/pupmod-simp-integration_tests.svg)](https://travis-ci.org/simp/pupmod-simp-integration_tests) [![SIMP compatibility](https://img.shields.io/badge/SIMP%20compatibility-6.*-orange.svg)](https://img.shields.io/badge/SIMP%20compatibility-6.*-orange.svg)

#### Table of Contents
<!-- vim-markdown-toc GFM -->

* [Description](#description)
  * [This is a SIMP project](#this-is-a-simp-project)
* [Setup](#setup)
  * [TODO: What integration_tests affects](#todo-what-integration_tests-affects)
  * [TODO: Setup Requirements **OPTIONAL**](#todo-setup-requirements-optional)
  * [Beginning with integration_tests](#beginning-with-integration_tests)
* [Usage](#usage)
* [Reference](#reference)
* [Limitations](#limitations)
* [Development](#development)
  * [Acceptance tests](#acceptance-tests)

<!-- vim-markdown-toc -->

## Description

Automated integration tests for SIMP.

Uses:

* beaker suites from [`simp-beaker-helpers`][simp-beaker-helpers]
* vagrant boxes build by [`simp-packer`][simp-packer]

### This is a SIMP project

This module is a tests components of the [System Integrity Management
Platform][simp].

If you find any issues, submit them to our [bug tracker][simp-jira].

## Setup

### TODO: What integration_tests affects


### TODO: Setup Requirements **OPTIONAL**

**FIXME:** Ensure the *Setup Requirements* section is correct and complete, then remove this message!

If your module requires anything extra before setting up (pluginsync enabled,
etc.), mention it here.

If your most recent release breaks compatibility or requires particular steps
for upgrading, you might want to include an additional "Upgrading" section
here.

### Beginning with integration_tests


```sh
BEAKER_vagrant_box_tree=$vagrant_boxes_dir \
BEAKER_box__puppetserver="simpci/server-6.2.0-RC1.el7-CentOS-7.0.x86-64" \
bundle exec rake beaker:suites
```

The very basic steps needed for a user to get the module up and running. This
can include setup steps, if necessary, or it can be an example of the most
basic use of the module.

## Usage

**FIXME:** Ensure the *Usage* section is correct and complete, then remove this message!

This section is where you describe how to customize, configure, and do the
fancy stuff with your module here. It's especially helpful if you include usage
examples and code samples for doing things with your module.

## Reference

**FIXME:** Ensure the *Reference* section is correct and complete, then remove this message!  If there is pre-generated YARD documentation for this module, ensure the text links to it and remove references to inline documentation.

Please refer to the inline documentation within each source file, or to the
module's generated YARD documentation for reference material.

## Limitations

**FIXME:** Ensure the *Limitations* section is correct and complete, then remove this message!

SIMP Puppet modules are generally intended for use on Red Hat Enterprise Linux
and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

**FIXME:** Ensure the *Development* section is correct and complete, then remove this message!

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).

### Acceptance tests

This module includes [Beaker](https://github.com/puppetlabs/beaker) acceptance
tests using the SIMP [Beaker Helpers](https://github.com/simp/rubygem-simp-beaker-helpers).
By default the tests use [Vagrant](https://www.vagrantup.com/) with
[VirtualBox](https://www.virtualbox.org) as a back-end; Vagrant and VirtualBox
must both be installed to run these tests without modification. To execute the
tests run the following:

```shell
bundle install
bundle exec rake beaker:suites
```

**FIXME:** Ensure the *Acceptance tests* section is correct and complete, including any module-specific instructions, and remove this message!

Please refer to the [SIMP Beaker Helpers documentation](https://github.com/simp/rubygem-simp-beaker-helpers/blob/master/README.md)
for more information.

[simp]:                     https://github.com/NationalSecurityAgency/SIMP
[simp-contrib]:             https://simp.readthedocs.io/en/master/contributors_guide/
[simp-jira]:                https://simp-project.atlassian.net
[simp-beaker-helpers]:      https://github.com/simp/rubygem-simp-beaker-helpers
[simp-beaker-helpers-docs]: https://github.com/simp/rubygem-simp-beaker-helpers/
[simp-packer]:              https://github.com/simp/simp-packer
