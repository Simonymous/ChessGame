Idee dieses Spiels
==================

Von aussen wird das hier wie ein normales Schachspiel aussehen, von einem technischen Standpunkt jedoch möchte ich folgende "Merkmale" implementieren:

1. Dezentralisierter Mehrspielermodus (aus Kostengründen und weil wirs können).
2. Keine Registrierung erforderlich.
3. Das Spiel muss wahlweise anonym, unter Pseudonym, oder unter echtem Namen spielbar sein.
4. Asynchrones Spielen.
5. Man muss Spiele abspeichern können (Spiele können ja länger als eine Vorlesung dauern ... wenn wir bessere Schachspieler wären :P).
6. Zuschauermodus.
7. Weitere kleine Vorteile der Speichermethode (Erklärung folgt).

## Im Bezug auf Netzwerkfunktionalität

Zum Testen arbeiten wir mit einer einfachen UDP-Verbindung. Im "Endprodukt" (ich denke schon an die ferne(?) Zukunft) arbeiten wir mit IPv6-Multicast.

## Interne Repräsentation des Spielstandes

Jedes Spiel fängt mit der Standardaufstellung an. Die Spieler wechseln sich gegenseitig ab und bewegen jeweils einen Spielstein pro Zug. Gespeichert wird daher in einer doppelt verketteten Liste (Jedes Element = Ein Spielzug).

Unter einem Spielzug versteht man intern einen String im Format `[SOURCE][DESTINATION]`, wobei sowohl `SOURCE` als auch `DESTINATION` aus den Koordinaten auf dem Spielfeld bestehen. Zum Beispiel: Bewegt weiß den linken Bauern um zwei nach vorne, so lautet der Spielzug `A2A4`. Man sollte beachten, dass der Spielzug weder den Typ des Spielsteines (hier Bauer), noch den Spieler (hier weiß) beinhaltet. Der Spielstein ergibt sich aus den Ursprungskoordinaten und den Spieler erhält man mit folgender Formel:

    s = no % 2
    no = Spielzug-Nummer
    s = 0: schwarz
    s = 1: weiß

Die Spieler schicken sich gegenseitig den Spielzug (die vier Zeichen, bspw. `A2A4`) und fügen ihn in die doppelt verkettete Liste ein.
Diese Liste kann selbstverständlich serialisiert, abgespeichert und geladen werden, sollte die Verbindung wegen Raumwechsels unterbrochen werden.
Man beachte auch, dass Netzwerk-Modul und doppelt verkettete Liste mit dem Spielzug (den vier Zeichen) selbst nicht arbeiten. Somit kann man mit wenig Aufwand jedes zugbasierte Mehrspielerspiel (Wir arbeiten einfach alles in https://de.wikipedia.org/wiki/Kategorie:Brettspiel ab ... haben ja noch 5 Semester) abspeichern und asynchron spielen.

Jetzt gibt es natürlich noch zwei Fragen:

1. Wie _meldet man sich an_ ?
2. Wie verhindert man Betrug ?

Beide Fragen haben die gleiche Antwort: __RSA__.

Zunächst einmal hat jedes Element der Liste (neben dem Spielzug selbst und Zeigern für nächstes und vorheriges Element) einen __SHA-256__-Hashwert, der aus dem Listenelement und dem __Hashwert des vorherigen Elementes__ besteht.
Durch die Einbeziehung des vorherigen Elementes in die Berechnung des aktuellen Hashwerts wird erreicht, dass ein zuvor bereits gespielter Spielzug (z.B. `A2A4`) nicht den gleichen Hashwert generiert, sollte er noch einmal gespielt werden.

Der Spielzug und der Hashwert des vorherigen Elementes werden auch über RSA-Schlüsselpaare von beiden Spielern __signiert__, bevor sie in die Liste eingefügt werden. Macht Spieler A seinen Zug, so sendet er Spieler B seinen Spielzug (`A2A4`) und die Signatur von Spielzug und vorherigem Hashwert. Als Antwort sendet Spieler B den gleichen Spielzug als Bestätigung zurück, nur mit seiner eigenen Signatur. Empfängt Spieler A die Bestätigung, dann haben beide Spieler den Zug als gültig empfunden und fügen auf ihren Rechnern Zug, beide Signaturen und Hashwert von Zug und beiden Signaturen in ihre Listen ein und der Spielzug gilt als getan.

Wie beantwortet das die Frage zur Anmeldung ?
Wie bereits erwähnt verwendet jedes Element den Hash des vorherigen Elementes zur Berechnung der eigenen Signaturen und Hashwerte. Doch was ist mit dem ersten Spielzug ? Wie lautet der Hashwert des vorherigen Elementes für den ersten Spielzug ? Antwort: Bevor ein Spiel startet wird in die Liste ein "nulltes" Element eingefügt. Der "Spielzug" ist jedoch kein echter Spielzug, sondern ein "Kennwort", welches beide Spieler vorher vereinbaren.

Haben sich zwei Spieler gefunden, so tauschen sie ihre öffentlichen RSA-Schlüssel zum Überprüfen ihrer Signaturen und das Spiel beginnt. Interessant ist hier der Ursprung des RSA-Schlüssels:

* Spielt man anonym, so wird der Schlüssel vor dem Match generiert.
* Spielt man unter Pseudonym, so verwendet man ein vorher generierten "anonymen" Schlüssel wieder und fügt einen Nutzernamen bei.
* Spielt man unter echtem Namen, so verwendet man einen bereits existierenden Schlüssel von __PGP__.

Über einen Zufallszahlentest bei Verwendung von PGP Schlüsseln stellt man sicher, dass sich beide Spieler kennen und der PGP Schlüssel des Gegenspielern kann man automatisch signieren lassen. Man baut sich damit spielerisch ein "Web of Trust", welches man in anderen PGP-Anwendungen (z.B. E-Mail) verwenden kann.

Beim Laden eines Spielstandes wird die Liste auf Fehler/Betrug überprüft. Dabei wird über die gesamte Liste iteriert und geschaut, ob Signaturen und Hashwerte aufgehen. Ist dies nicht der Fall (Im Zweifelsfalle für den Angeklagten, kann ja auch ein Speicherfehler sein), so kann ein Spieler sich den Rest der Liste vom Gegenspieler herunterladen ohne Gefahr zu laufen, dass besagter Spieler die Liste selbst manipuliert hat.

Wenn das Netzwerkmodul IPv6-Multicast verwendet, dann müssen wir noch nicht mal explizit einen Zuschauermodus einbauen, weil jedes Mitglied im Netzwerk die Pakete erhält, aber nur zwei Mitglieder im Netzwerk, die Spieler selbst, die richtigen RSA-Schlüssel zum Spielen besitzen.
