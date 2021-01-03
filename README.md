# Linux - Opdracht 3 Documentatie

In deze opdracht maken we gebruik van de eerder aangemaakte Nomad-cluster waar we een simpele [httpd](https://httpd.apache.org/docs/2.4/programs/httpd.html) webserver op draaien over 2 nodes. Deze nodes worden gemonitord, we exposen de metrics van deze endpoints met [node_exporter](https://github.com/prometheus/node_exporter). Deze metrics worden opgevangen door een [Prometheus](https://hub.docker.com/r/prom/prometheus/)-instantie en ze worden gevisualiseerd gebruikmakend van [Grafana](https://hub.docker.com/r/grafana/grafana).


## Poorten
`:9999` = [Fabio](https://github.com/fabiolb/fabio) loadbalancer endpoint.

`:9998` = Fabio GUI

`:4646` = Nomad

`:3000` = Grafana 

`:9090` = Prometheus

`:9100` = node_exporter metrics endpoint 


## .nomad jobs

De gebruikte .nomad jobs zijn terug te vinden in de map [nomad/](https://github.com/JorenSpinnoy/PXL_nomad/tree/team1-pe3/nomad). Start de jobs in onderstaande volgorde: 

* fabio
* node-exporter
* prometheus
* grafana
* webserver

## Prometheus queries (PromQL)

#### CPU time (user) percentage
``` 
rate(node_cpu_seconds_total{mode="user"}[30s]) * 100
```

## Grafana dashboard
Het .json-template voor ons Grafana dashboard is terug te vinden in de map [grafana/](https://github.com/JorenSpinnoy/PXL_nomad/tree/team1-pe3/grafana). Deze template kan je importeren in Grafana door op het + icoontje in het side menu te drukken. Hier kan je de .json-file uploaden of gewoon de inhoud in het json panel plakken.