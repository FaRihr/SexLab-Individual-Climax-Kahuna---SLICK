import re

MCMscript = "source/scripts/slcConfig.psc"
TransBaseName = "Interface/Translations/SLICK_"

# All languages supported by SkyUI MCM
languages = {"czech", "english", "french", "german", "italian", "japanese", "polish", "russian", "spanish"}

print("Searching... ", end="")

# build up list of all replacers
found = list()
with open(MCMscript, "r", encoding="utf_8") as f:
    found = re.findall("\$[\w_]+", f.read())
    f.close()

placeholders = set(found) # remove duplicates
del(found)

# iterate every language and append missing replacers at the end
for language in languages:
    uniques = placeholders.copy()

    # remove replacers that are already present in translation file
    try:
        found = list()
        with open(TransBaseName + language.upper() + ".txt", "r", encoding="utf_16_le") as f:
            found = re.findall("\$[\w_]+", f.read())

            for finding in found:
                uniques.discard(finding)

            f.close()

        del(found)
    except:
        pass

    uniques.discard("$Yes")
    uniques.discard("$No")

    # if there are missing replacers, append them to translation file
    if len(uniques) > 0:
        with open(TransBaseName + language.upper() + ".txt", "a+", encoding="utf_16_le") as f:
            f.write("\n")
            f.write("\n\t".join(sorted(uniques)))

            f.close()

        print(language + ", ", end="")

print("done!")