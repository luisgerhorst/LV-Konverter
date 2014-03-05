# Struktur der CSV-Datei

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

Bei der Implementierung des D83-Formats wurde auf die [Regelungen für den Datenaustausch Leistungsverzeichnis](http://www.gaeb.de/download/da1990.pdf) (2., geänderte Auflage) von Juni 1990 zurückgegriffen.

# Support

Bei Fragen, Anmerkungen und Verbesserungsvorschlägen schicken Sie eine Mail an [luis@luisgerhorst.de](mailto:luis@luisgerhorst.de).
