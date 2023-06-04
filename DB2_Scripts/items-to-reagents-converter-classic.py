#!/usr/bin/python3
import csv

spell_to_item = {}
spell_to_quantity = {}

# Connect spell effects which make icons with the item
with open('SpellEffect.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        effect = int(row['Effect'])
        spell_id = int(row['SpellID'])
        item_id = int(row['EffectItemType'])
        if item_id != 0:
            spell_to_item[spell_id] = [item_id]
            base_points = int(row['EffectBasePoints'])
            bonus_coefficient = int(row['EffectBonusCoefficient'])
            group_coefficient = int(row['GroupSizeBasePointsCoefficient'])
            spell_to_quantity[spell_id] = base_points + bonus_coefficient + group_coefficient
            

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
    reagents = spell_to_reagents[spell_id]
    quantity = spell_to_quantity[spell_id]
    result = ""
    result = result + "[" + str(spell_id) + "]={reagents={"
    for slot in reagents:
        result = result + "{items={"
        for r in slot[0]:
            result = result + str(r) + ","
        result = result + "},quantity=" + str(slot[1]) + "},"
    result = result + "},quantity=" + str(quantity) + "},"
    return result

ordered_spells = []
ordered_items = []
item_to_spells = {}
for spell_id in spell_to_reagents:
    if spell_id in spell_to_item:
        ordered_spells.append(spell_id)
        for item_id in spell_to_item[spell_id]:
            if item_id not in item_to_spells:
                ordered_items.append(item_id)
                item_to_spells[item_id] = []
            item_to_spells[item_id].append(spell_id)
ordered_spells.sort()
ordered_items.sort()

def spells_list_str(item_id):
    result = "[" + str(item_id) + "]={"
    for spell_id in item_to_spells[item_id]:
        result = result + str(spell_id) + ","
    result = result + "},"
    return result

print("CraftInfoAnywhere.Data={}")
print("CraftInfoAnywhere.Data.ItemsToRecipes={")
for item_id in ordered_items:
    print(spells_list_str(item_id))
print("}")
print("CraftInfoAnywhere.Data.Recipes={")
for spell_id in ordered_spells:
    print(reagents_details_str(spell_id))
#    tmp = reagents_details_str(spell_id)
print("}")
