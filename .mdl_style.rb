# Enable every rule, then adjust: without this line only the rules listed below apply
all

# Hard tabs: a real tab in a code block is data (git check-ignore output), not indentation
rule 'MD010', :ignore_code_blocks => true

# Line length: prettier wraps prose at .editorconfig max_line_length; tables and code spans it cannot break
rule 'MD013', :line_length => 140, :tables => false

# Inconsistent list indentation: sub-items under "1." sit at 3 spaces (prettier), kramdown reads them as inconsistent
exclude_rule 'MD005'

# Unordered list indentation: prettier owns it; kramdown flags nested "-" items it cannot attach
exclude_rule 'MD007'

# Ordered list prefix: an item with a nested code block splits the list for kramdown, "2." then reads as a new list
exclude_rule 'MD029'

# Table row pipes: "<a | b>" placeholders in templates read as table rows
exclude_rule 'MD055'

# Table column count: an escaped "\|" in a cell (curl \| sh) is counted as a separator
exclude_rule 'MD056'

# Table header separation: same placeholder false positive as MD055; prettier already validates tables
exclude_rule 'MD057'

# First header level: agent fiches open with their prompt and use "##" sections, no title
exclude_rule 'MD002'

# Inline HTML: "<nom>", "<fichier>" placeholders in templates are not HTML
exclude_rule 'MD033'

# First line header: same as MD002, the fiche body starts with "You are …"
exclude_rule 'MD041'
