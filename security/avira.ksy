meta:
  id: qua
  file-extension: qua
  endian: le
  title: Avira Antivirus quarantine file parser
  license: MIT
  ks-version: 0.9
doc: |
  Creator: Florian Bausch, ERNW Research GmbH, https://ernw-research.de
  License: MIT
  https://github.com/ernw/quarantine-formats/blob/master/docs/Avira_Antivirus.md
  Avira Antivirus quarantine files are usually stored under /ProgramData/Avira/Antivirus/INFECTED.
  The file extension usually is .qua.
seq:
  - id: magic
    size: 16
    contents: ["AntiVir Qua", 0x00, 0x00, 0x00, 0x00, 0x00]
  - id: malicious_offset
    type: u4
    doc: Points to the beginning of the xored malware.
  - id: len_filename
    type: u4
  - id: len_addl_info
    type: u4
  - id: unknown1
    size: 0x20
  - id: qua_time
    type: u4
    doc: Unix timestamp when the suspected malware was quarantined.
  - id: unknown2
    size: 0x5c
  - id: mal_type
    type: str
    terminator: 0
    encoding: UTF-8
    size: 0x40
    doc: The string that contains the name of the suspected malware.
  - id: filename
    type: str
    encoding: UTF-16LE
    size: 'len_filename < 2 ? len_filename : len_filename - 2'
    doc: The original filename where the malware was detected. Sometimes seems to be a process name.
  - id: padding1
    size: 2
    contents: [0x00, 0x00]
    if: 'len_filename >= 2'
  - id: addl_info
    type: str
    encoding: UTF-16LE
    size: 'len_addl_info < 2 ? len_addl_info : len_addl_info - 2'
    doc: More information, but often empty.
  - id: padding2
    size: 2
    contents: [0x00, 0x00]
    if: 'len_addl_info >= 2'
  - id: mal_file
    process: xor(0xaa)
    size-eos: true
    doc: The quarantined file, xored with 0xAA.
instances:
  mal_file_offset:
    pos: malicious_offset
    process: xor(0xaa)
    size-eos: true
    doc: The malware file retrieved using the malicious_offset field.
