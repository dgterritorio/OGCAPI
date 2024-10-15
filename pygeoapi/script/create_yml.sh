#!/bin/bash

# Verifica se il numero di argomenti è corretto
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 lista_nomi.txt template.yml"
  exit 1
fi

# Leggi gli argomenti
file_lista_nomi="$1"
file_template="$2"
output_file="output.yml"

# Verifica se i file di input esistono
if [ ! -f "$file_lista_nomi" ]; then
  echo "Errore: il file $file_lista_nomi non esiste."
  exit 1
fi

if [ ! -f "$file_template" ]; then
  echo "Errore: il file $file_template non esiste."
  exit 1
fi

# Cancella il file di output se esiste già
> "$output_file"

# Leggi ogni nome dalla lista e genera un blocco nel file di output
while IFS= read -r nome; do
  # Sostituisci la stringa segnaposto nel template
  sed "s/{{NOME}}/$nome/g" "$file_template" >> "$output_file"
  echo "" >> "$output_file"  # Aggiungi una linea vuota per separare i blocchi

done < "$file_lista_nomi"

echo "File $output_file generato con successo."
