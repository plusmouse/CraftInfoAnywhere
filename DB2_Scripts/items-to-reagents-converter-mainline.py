#!/usr/bin/python3
import csv
import math

spell_to_item = {}
spell_to_quantity = {}
is_enchant = {}
EnchantingVellumID = 38682

# Get the DF quality items as they use a different stat to connect them to the
# result
crafting_ids_to_item = {}

with open('CraftingData.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        crafting_id = int(row['ID'])
        item_id = int(row['CraftedItemID'])
        if item_id != 0:
            crafting_ids_to_item[crafting_id] = [item_id]

with open('CraftingDataItemQuality.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        crafting_id = int(row['CraftingDataID'])
        if crafting_id not in crafting_ids_to_item:
            crafting_ids_to_item[crafting_id] = []
        item_id = int(row['ItemID'])
        crafting_ids_to_item[crafting_id].append(item_id)

with open('CraftingDataEnchantQuality.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        crafting_id = int(row['CraftingDataID'])
        if crafting_id not in crafting_ids_to_item:
            crafting_ids_to_item[crafting_id] = []
        item_id = int(row['ItemID'])
        crafting_ids_to_item[crafting_id].append(item_id)

mcc_to_spell_id = {}

# Connect spell effects which make icons with the item
with open('SpellEffect.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        effect = int(row['Effect'])
        spell_id = int(row['SpellID'])
        spell_to_quantity[spell_id] = math.ceil(float(row['EffectBasePointsF']))
        # DF items don't, so we special case and use the values generated above
        # to figure out the items it could be
        if effect == 288 or effect == 301:
            misc_effect_0 = int(row['EffectMiscValue_0'])
            if misc_effect_0 in crafting_ids_to_item:
                mcc_to_spell_id[misc_effect_0] = spell_id
                item_id = crafting_ids_to_item[misc_effect_0][0]
                spell_to_item[spell_id] = crafting_ids_to_item[misc_effect_0]
                if effect == 301:
                    is_enchant[spell_id] = True
        # Most items just have the data stored in the row
        elif effect != 288:
            item_id = int(row['EffectItemType'])
            if item_id != 0:
                spell_to_item[spell_id] = [item_id]
                if effect  == 53:
                    is_enchant[spell_id] = True

spell_to_skill_line = {}

with open('SkillLineAbility.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_id = int(row['Spell'])
        skill_line_id = int(row['SkillLine'])
        spell_to_skill_line[spell_id] = skill_line_id

skill_line_to_prof_spell = {}

with open('SkillLine.csv', newline='') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_id = int(row['SpellBookSpellID'])
        if spell_id != 0:
            skill_line_id = int(row['ID'])
            skill_line_to_prof_spell[skill_line_id] = spell_id

spell_to_reagents = {}

with open('SpellReagents.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_id = int(row['SpellID'])
        reagents = []
        for i in range(0, 8):
            reagent_item_id = int(row['Reagent_' + str(i)])
            reagent_quantity = int(row['ReagentCount_' + str(i)])
            if reagent_item_id != 0 and reagent_quantity != 0:
                reagents.append(([reagent_item_id], reagent_quantity))
        spell_to_reagents[spell_id] = reagents

mcc_id_to_items = {}
with open('CraftingReagentQuality.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        item_id = int(row['ItemID'])
        wanted_id = int(row['ModifiedCraftingCategoryID'])
        if wanted_id not in mcc_id_to_items:
            mcc_id_to_items[wanted_id] = []
        mcc_id_to_items[wanted_id].append(item_id)

reagent_slot_to_items = {}
with open('MCRSlotXMCRCategory.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        slotid = int(row['ModifiedCraftingReagentSlotID'])
        mcc = int(row['ModifiedCraftingCategoryID'])
        if mcc in mcc_id_to_items:
            reagent_slot_to_items[slotid] = mcc_id_to_items[mcc]

with open('ModifiedCraftingReagentSlot.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        slot_id = int(row['ID'])
        slot_type = int(row['ReagentType'])
        if slot_type != 1 and slot_id in reagent_slot_to_items:
            del reagent_slot_to_items[slot_id]

with open('ModifiedCraftingSpellSlot.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_id = int(row['SpellID'])
        slot_id = int(row['ModifiedCraftingReagentSlotID'])
        count = int(row['ReagentCount'])
        if slot_id in reagent_slot_to_items:
            if spell_id not in spell_to_reagents:
                spell_to_reagents[spell_id] = []
            spell_to_reagents[spell_id].append((reagent_slot_to_items[slot_id], count))

for spell_id in is_enchant:
    if spell_id in spell_to_reagents:
        spell_to_reagents[spell_id].append(([EnchantingVellumID], 1))
        spell_to_quantity[spell_id] = 1

seen_skill_lines = {}
ordered_skill_lines = []
ordered_spells = []
for spell_id in spell_to_reagents:
    if spell_id in spell_to_item and spell_id in spell_to_skill_line:
        skill_line_id = spell_to_skill_line[spell_id]
        if skill_line_id in skill_line_to_prof_spell:
            ordered_spells.append(spell_id)
            if skill_line_id not in seen_skill_lines:
                seen_skill_lines[skill_line_id] = True
                ordered_skill_lines.append(skill_line_id)
ordered_spells.sort()
ordered_skill_lines.sort()

item_to_spells = {}
ordered_items = []
for spell_id in ordered_spells:
    for item_id in spell_to_item[spell_id]:
        if item_id not in item_to_spells:
            item_to_spells[item_id] = []
            ordered_items.append(item_id)
        item_to_spells[item_id].append(spell_id)
ordered_items.sort()

reagents_to_items = {}
reagents_to_spells_only = {}

for spell_id in spell_to_skill_line:
    if spell_id in spell_to_reagents:
        reagents = spell_to_reagents[spell_id]
        if spell_id in spell_to_item:
            for item_id in spell_to_item[spell_id]:
                for reagent_details in reagents:
                    for reagent in reagent_details[0]:
                        if reagent not in reagents_to_items:
                            reagents_to_items[reagent] = []
                        reagents_to_items[reagent].append(item_id)
        else:
            for reagent_details in reagents:
                for reagent in reagent_details[0]:
                    if reagent not in reagents_to_spells_only:
                        reagents_to_spells_only[reagent] = []
                    reagents_to_spells_only[reagent].append(spell_id)

ordered_reagents = []
for reagent in reagents_to_items:
    reagents_to_items[reagent].sort()
    ordered_reagents.append(reagent)
ordered_reagents.sort()

ordered_reagents_2 = []

for reagent in reagents_to_spells_only:
    reagents_to_spells_only[reagent].sort()
    ordered_reagents_2.append(reagent)
ordered_reagents_2.sort()


# Assumes spell_id in spell_to_item and spell_id in spell_to_reagents
def reagents_details_str(spell_id):
    reagents = spell_to_reagents[spell_id]
    skill_line = spell_to_skill_line[spell_id]
    quantity = 1
    if spell_id in spell_to_quantity:
        quantity = spell_to_quantity[spell_id]
    result = ""
    result = result + "[" + str(spell_id ) + "]={reagents={"
    for slot in reagents:
        result = result + "{items={"
        for r in slot[0]:
            result = result + str(r) + ","
        result = result + "},quantity=" + str(slot[1]) + "},"
    result = result + "},quantity=" + str(quantity) + ","
    result = result + "skillLine=" + str(skill_line) + "},"
    return result

def skill_line_spell_str(skill_line_id):
    result = "[" + str(skill_line_id) + "]=" + str(skill_line_to_prof_spell[skill_line_id]) + ","
    return result

def spells_list_str(item_id):
    result = "[" + str(item_id) + "]={"
    for spell_id in item_to_spells[item_id]:
        result = result + str(spell_id) + ","
    result = result + "},"
    return result

def reagent_to_items_str(reagent):
    all_items = reagents_to_items[reagent]
    result = "[" + str(reagent) + "]={"
    for item_id in all_items:
        result = result + str(item_id) + ","
    result = result + "},"
    return result

def reagent_to_spells_str(reagent):
    all_spells = reagents_to_spells_only[reagent]
    result = "[" + str(reagent) + "]={"
    for spell_id in all_spells:
        result = result + str(spell_id) + ","
    result = result + "},"
    return result

print("CraftInfoAnywhere.Data={}")
print("CraftInfoAnywhere.Data.ItemsToRecipes={")
for item_id in ordered_items:
    print(spells_list_str(item_id))
print("}")
print("CraftInfoAnywhere.Data.ReagentsToItems={")
for reagent in ordered_reagents:
    print(reagent_to_items_str(reagent))
print("}")
print("CraftInfoAnywhere.Data.ReagentsToSpells={")
for reagent in ordered_reagents_2:
    print(reagent_to_spells_str(reagent))
print("}")
print("CraftInfoAnywhere.Data.Recipes={")
for spell_id in ordered_spells:
    print(reagents_details_str(spell_id))
    #tmp = reagents_details_str(spell_id)
print("}")
print("CraftInfoAnywhere.Data.SkillLinesToSpells={")
for spell_id in ordered_skill_lines:
    print(skill_line_spell_str(spell_id))
print("}")
