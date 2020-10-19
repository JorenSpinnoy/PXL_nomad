# Nomad consul

The aim of this project is to provide a development environment based on [consul](https://www.consul.io) and [nomad](https://www.nomadproject.io) to manage container based microservices.

The following steps should make that clear;

bring up the environment by using [vagrant](https://www.vagrantup.com) which will create centos 7 virtualbox machine or lxc container.

The proved working vagrant providers used on an [ArchLinux](https://www.archlinux.org/) system are
* [vagrant-lxc](https://github.com/fgrehm/vagrant-lxc)
* [vagrant-libvirt](https://github.com/vagrant-libvirt/)
* [virtualbox](https://www.virtualbox.org/)

```bash
    $ vagrant up --provider lxc
    OR
    $ vagrant up --provider libvirt
    OR
    $ vagrant up --provider virtualbox
```

Once it is finished, you should be able to connect to the vagrant environment through SSH and interact with Nomad:

```bash
    $ vagrant ssh
    [vagrant@nomad ~]$
```

# Linux - Opdracht 1 (deadline 26/10)

Per 2 (overzicht), met behulp van de vagrant shell provisioner een nomad cluster opzetten door middel van de tijdens de les gebruikte technieken toe te passen.

Een productie waardige nomad cluster met consul als service discovery en docker als driver installeren, configureren en starten door gebruik te maken van de vagrant shell provisioner in een vagrant multi machine omgeving. 

In de vagrant file worden 3 vm's aangemaakt waarvan eentje zal dienen als nomad server en de overige 2 als nomad agent. Op de 3 nodes moet consul worden geinstalleerd en geconfigureerd als cluster waartegen de nomad server communiceert.

De nomad server consul configuratie mag geconfigureerd worden zodat de nomad agents automatisch joinen.

Nomad, consul en docker dienen te worden opgezet met systemd (de voorziene yum repository van HashiCorp mag gebruikt worden!)

Het commando vagrant up --provision is het enige commando dat gebruikt zal worden om jullie nomad setup op te brengen waarna er getracht zal worden om een simpele webserver job definitie op jouw cluster zal worden uitgetest.

Het eindresultaat dient via git te worden gepushed op de https://github.com/visibilityspots/PXL_nomad github repository op de branch van jouw team ten laatste op 26/10/2020 om 23:59:59.

Een README dient te worden opgesteld met een uitleg wat jullie gedaan hebben en waarom samen met een bron vermelding.

De quotering zal gebeuren enerzijds op het functionele aspect van je cluster, anderzijds wordt er ook gekeken naar het gebruik van best practices van de gehanteerde oplossing alsook de samenwerking tussen jullie beiden en een individuele bevraging tijdens het evaluatie moment.
