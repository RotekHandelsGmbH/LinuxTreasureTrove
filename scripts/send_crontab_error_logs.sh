#!/usr/bin/env bash

# Kurze Beschreibung:
# Dieses Skript sendet eine E-Mail mit dem Inhalt eines angegebenen Logfiles
# und hängt das Logfile als Anhang an. Es verwendet 'mutt' zum Versenden der E-Mail.

# Eingabeparameter prüfen
if [[ $# -ne 3 ]]; then
    echo "Usage: $0 <SCRIPT> <LOGFILE> <EMAIL>"
    echo "Erwartete Parameter:"
    echo "  <SCRIPT>: Der vollständige Pfad zum ausgeführten Skript."
    echo "  <LOGFILE>: Der vollständige Pfad zur Logdatei, die gesendet werden soll."
    echo "  <EMAIL>: Die Ziel-E-Mail-Adresse, an die die Nachricht gesendet wird."
    exit 1
fi

# Übergabeparameter
SCRIPT="${1}"  # Pfad des ausgeführten Scripts
LOGFILE="${2}"  # Pfad zum Logfile
EMAIL="${3}"    # Ziel-E-Mail-Adresse

# Einstellungen
SHORT_HOSTNAME=$(hostname -s)  # Kurzform des Hostnamens
SENDER="crontab@$(hostname)"  # Absender der E-Mail
SUBJECT="${SHORT_HOSTNAME} : ERROR in crontab on script $(basename ${SCRIPT})"  # Betreff der E-Mail
ERROR_LOG="/var/log/$(basename \\"${0}")_error.log"  # Fehler-Logdatei

# Fehler-Logdatei vor jedem Durchlauf löschen
# shellcheck disable=SC2188
> "${ERROR_LOG}"

# Überprüfen, ob die erforderlichen Dateien vorhanden sind
if [[ ! -f "${LOGFILE}" ]]; then
    echo "Logfile ${LOGFILE} existiert nicht." | tee -a "${ERROR_LOG}"
    exit 1
fi

# Überprüfen, ob mutt installiert ist
if ! command -v mutt &>/dev/null; then
    echo "Das Programm 'mutt' ist nicht installiert. Bitte installieren Sie es und versuchen Sie es erneut." | tee -a "${ERROR_LOG}"
    exit 1
fi

# E-Mail senden mit Timeout und Retry-Mechanismus
ATTEMPTS=3
SUCCESS=0
for (( i=1; i<=ATTEMPTS; i++ )); do
    mutt -e "set from=${SENDER}" -s "${SUBJECT}" -a "${LOGFILE}" -- "${EMAIL}" < "${LOGFILE}"

    if [[ $? -eq 0 ]]; then
        SUCCESS=1
        echo "E-Mail erfolgreich gesendet an ${EMAIL} mit Anhang ${LOGFILE}." | tee -a "${ERROR_LOG}"
        break
    else
        echo "Fehler beim Senden der E-Mail. Versuch ${i} von ${ATTEMPTS} fehlgeschlagen." | tee -a "${ERROR_LOG}"
        sleep 5  # Kurze Pause vor dem nächsten Versuch
    fi

done

if [[ ${SUCCESS} -ne 1 ]]; then
    echo "Fehler: Alle ${ATTEMPTS} Versuche zum Senden der E-Mail sind fehlgeschlagen." | tee -a "${ERROR_LOG}"
    exit 1
fi
