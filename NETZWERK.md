Netzwerk
========

Bei der Art der Netzwerkverbindung müssten wir versuchen, genau so modular und erweiterbar zu arbeiten, wie bei allen anderen Elementen des Spiels. Der Einfachheit halber fangen wir mit einer einfachen UDP-Verbindung an und arbeiten uns bis zu unserem Ziel: IPv6-Multicast. Recherche zu den beiden Verbindungstypen auf eigene Hand, Wikipedia, Google oder Fabian.

# Protokoll

Bei UDP gibt es keine Bestätigung, ob Pakete wirklich angekommen sind. Normalerweise lösen das Programme über ACK-Pakete (senden also ein Bestätigungspaket nach jedem erhaltenen UDP-Paket). Um unnötigen Overhead zu vermeiden tun wir das nicht und lösen dieses Problem über das Protokoll.

## Schlüsseltausch

### PROPAGATE-KEY

    KEY-A-PUBKEY
    KEY-P-NAME-PUBKEY
    KEY-G-PUBKEY

* `KEY`: Hash des vorher vereinbarten Kennworts
* `A/P/G`: Anonymer Schlüssel/Pseudonym/GNU-PGP
* `PUBKEY`: Öffentlicher Schlüssel

Bestätigungspaket: `CONFIRM-KEY`

### CONFIRM-KEY

    SECRET-A-PUBKEY
    SECRET-P-NAME-PUBKEY
    SECRET-G-PUBKEY

* `SECRET`: Mit dem öffentlichen Schlüssel des Gegenspielers verschlüsseltes Geheimnis
* `A/P/G`: Anonymer Schlüssel/Pseudonym/GNU-PGP
* `PUBKEY`: Öffentlicher Schlüssel

Bestätigungspaket: `TURN`

### TURN

    KEY-MOVE-SIGNATURE-HASH

* `KEY`: Hash des vorher vereinbarten Kennworts (dient jetzt als Bezeichner für das Match selbst).
* `MOVE`: Spielzug.toString()
* `SIGNATURE`: `MOVE-PREV`, verschlüsselt mit `PUBKEY` des Gegenspielers.
* `PREV`: Hashwert des letzten Elements der Liste.
* `HASH`: `MOVE-SIGNATURE`, verhasht mit SHA-256.

Bestätigungspaket: Nächster `TURN`

### PULL

    KEY-FROM-HASH
    KEY-FROM-TO-HASH
    KEY-ALL

* `KEY`: Hash des vorher vereinbarten Kennworts (dient jetzt als Bezeichner für das Match selbst).
* `FROM`, `TO`: Bereich der Liste, die heruntergeladen werden soll.
  * `0`: Letzter gemeinsamer `TURN`
* `HASH`: Übertragungsprüfhash

Bestätigungspaket: Alle `TURN`s des Bereichs
