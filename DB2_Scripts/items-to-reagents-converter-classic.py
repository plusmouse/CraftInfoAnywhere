#!/usr/bin/python3
import csv

spell_to_item = {}

# Connect spell effects which make icons with the item
with open('SpellEffect.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        effect = int(row['Effect'])
        spell_id = int(row['SpellID'])
        item_id = int(row['EffectItemType'])
        if item_id != 0:
            spell_to_item[spell_id] = [item_id]

spell_to_reagents = {}

with open('SpellReagents.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_id = int(row['SpellID'])
        if spell_id in spell_to_item:
            reagents = []
            for i in range(0, 8):
                reagent_item_id = int(row['Reagent_' + str(i)])
                reagent_quantity = int(row['ReagentCount_' + str(i)])
                if reagent_item_id != 0 and reagent_quantity != 0:
                    reagents.append(([reagent_item_id], reagent_quantity))
            spell_to_reagents[spell_id] = reagents

# Assumes spell_id in spell_to_item and spell_id in spell_to_reagents
def reagents_details_str(spell_id):
    item_ids = spell_to_item[spell_id]
    reagents = spell_to_reagents[spell_id]
    result = ""
    for item_id in item_ids:
        result = result + "[" + str(item_id) + "]={spell=" + str(spell_id) + ",reagents={"
        for slot in reagents:
            result = result + "{items={"
            for r in slot[0]:
                result = result + str(r) + ","
            result = result + "},quantity=" + str(slot[1]) + "},"
        result = result + "}},"
    return result

ordered_spells = []
for spell_id in spell_to_reagents:
    if spell_id in spell_to_item:
        ordered_spells.append(spell_id)
ordered_spells.sort()
    

print("CraftInfoAnywhere.Data = {")
for spell_id in ordered_spells:
    print(reagents_details_str(spell_id))
#    tmp = reagents_details_str(spell_id)
print("}")
