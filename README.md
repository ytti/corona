# About
  Corona sends SNMP queries to defined CIDR ranges and populates SQL database based on nodes found. Some particular problems it tries to deal with:
  * Only discover one node once
  * To that effect it has priority list of idDescr lo0.0, loopback0, vlan2 etc. Higher priority will always replace lower priority interface (say you have MGMT in loop0 but giga0/2.42 has valid MGMT address towards L2 metro)
  * Tries to handle gracefully renumbering, renaming, etc

# Install
  1. gem install corona
  2. corona
  3. ^C (break it)
  4. edit ~/.config/corona/config 
  5. put corona in crontab as _corona|mail -E -s 'new nodes found' foo@example.com_

# Config
  * You need to configure SNMP community
  * You need to define CIDR to poll and CIDRs to ignore (subset of those you poll)
  * CIDR in example config is list, but can be replaced with 'string' which points to file, where CIDRs are listed
