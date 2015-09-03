# LV Konverter

Mithilfe dieses Programmes können Sie ganz einfach am Mac Leistungsverzeichnisse im D83-Format erstellen indem Sie das LV in einem beliebigen Tabellenkalkulationsprogramm (Numbers, Excel oder OpenOffice Calc) nach einer bestimmten Struktur erstellen, die Tabelle als CSV-Datei exportieren und diese dann anschließend mit LV Konverter ins D83-Format umwandeln.

# Installation

Laden Sie unter [Releases](https://github.com/luisgerhorst/LV-Konverter/releases) die neueste Version herunter und verschieben Sie das Programm anschließend in Ihren Programmordner.

Öffnen Sie das Programm, __wenn Sie eine Meldung erhalten das LV Konverter nicht geöffnet werden kann__ da es von einem nicht verifizierten Entwickler stammt, gehen Sie im Menü auf "Apple" > "Systemeinstellungen …" > "Sicherheit" > "Allgemein". Hier können Sie LV Konverter erlauben geöffnet zu werden. Allgemeine Infos zu Gatekeeper bzw. dem öffnen von Programmen von nicht verifizierten Entwicklern finden Sie auf der Apples Webseite [OS X: Informationen zu Gatekeeper](https://support.apple.com/de-de/HT202491).

# Benutzung

Um die CSV-Datei zu konvertieren öffnen Sie sie einfach mit LV Konverter, anschließend werden Probleme angezeigt die bei der Formatierung der Tabelle gemacht wurden. _Warnungen_ können ignoriert werden aber vor allem _Fehler_ sollten Sie beheben bevor Sie fortfahren. Danach können Sie die in der D83-Datei enthaltenen informationen ergänzen und danach den Speicherort für die D83-Datei auswählen.

# Struktur der Tabelle

Um eingelesen werden zu können muss die CSV-Datei einen bestimmten Aufbau haben.

Des weiteren sollten Sie Umlaute und sämmtliche andere Zeichen die nicht [ASCII](http://de.wikipedia.org/wiki/American_Standard_Code_for_Information_Interchange)-Zeichensatz enthalten sind vermeiden, da diese beim Speichern im D83-Format umgewandelt werden müssen.

## Allgemein

Die Datei muss aus mindestens fünf Spalten bestehen.

Ordnungszahl | Text | Menge | Einheit | Art
---          | ---  | ---   | ---     | ---
...          | ...  | ...   | ...     | ...

Lehrzeilen werden ignoriert.

## LV-Gruppen

Ordnungszahl | Text | Menge | Einheit | Art
---          | ---  | ---   | ---     | ---
1           | Bezeichnung / Titel der LV-Gruppe |

Ordnungszahl und die Spalte "Text" die den Titel der LV-Gruppe enthält müssen belegt sein.

Menge, Einheit und Art müssen leer sein.

## Teilleistungen

Ordnungszahl | Text | Menge | Einheit | Art
---          | ---  | ---   | ---     | ---
1.1          | Kurztext / Titel | 2.75 | m2   | BG
             | Langtext / Beschreibung
             | weitere Zeilen des Langtextes ...

* __Ordnungszahl:__ Muss belegt sein.
* __Text__ in Zeile mit Ordnungszahl: Kurztext bzw. Titel, max 70 Stellen.
* __Menge:__ Zahl, mit oder ohne Komma, muss größer `0` sein.
* __Einheit:__ Max 4 Stellen, _Stundenlohnarbeiten_ die in `h` gemessen werden, werden automatisch als solche erkannt. `psch` für Pauschalleistungen (mit Menge 1).
* __Text__ alle Zeilen bis zum Beginn der nächsten Teilleistung/LV-Gruppe: Langtext der Teilleistung, eine Zeile sollte nicht mehr als 55 Stellen habe. Optional.
* __Art:__
	* kein Inhalt: Normalposition
	* BG: Bedarfsposition mit Gesamtbetrag
	* BE: Bedarfsposition ohne Gesamtbetrag

Alle Felder bis auf den Langtext und die Art müssen immer belegt sein.

# Quellen

Bei der Implementierung des D83-Formats wurde auf die [Regelungen für den Datenaustausch Leistungsverzeichnis](Regelungen für den Datenaustausch Leistungsverzeichnis.pdf) (2., geänderte Auflage) von Juni 1990 zurückgegriffen. Ursprüngliche Quelle: http://www.gaeb.de/download/da1990.pdf

# Support

Bei Fragen, Anmerkungen und Verbesserungsvorschlägen schicken Sie eine Mail an [luis@luisgerhorst.de](mailto:luis@luisgerhorst.de).
