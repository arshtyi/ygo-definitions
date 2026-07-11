# Download mask data
setup:
    mkdir -p assets
    curl -fsSL https://raw.githubusercontent.com/arshtyi/ygo-cards/main/config/ot-field-mappings.json -o assets/ot-field-mappings.json
    curl -fsSL https://raw.githubusercontent.com/arshtyi/ygo-cards/main/config/rd-field-mappings.json -o assets/rd-field-mappings.json
    cd assets && sha256sum ot-field-mappings.json  > ot-field-mappings.json.sha256sum
    cd assets && sha256sum rd-field-mappings.json  > rd-field-mappings.json.sha256sum

# Compile the Typst document
compile:
    typst compile docs.typ docs.pdf

# Watch and compile the Typst document
watch:
    typst watch docs.typ docs.pdf
