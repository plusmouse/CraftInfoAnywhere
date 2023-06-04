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

spell_to_skill_line = {}
skill_line_to_prof_spell = {}

with open('SkillLineAbility.csv') as f:
    reader = csv.DictReader(f, delimiter=',')
    for row in reader:
        spell_id = int(row['Spell'])
        skill_line = int(row['SkillLine'])
        spell_to_skill_line[spell_id] = skill_line
        supercedes_spell_id = int(row['SupercedesSpell'])
        min_skill_line_rank = int(row['MinSkillLineRank'])
        if min_skill_line_rank == 1 and supercedes_spell_id != 0:
            if skill_line in skill_line_to_prof_spell:
                skill_line_to_prof_spell[skill_line] = min(skill_line_to_prof_spell[skill_line], supercedes_spell_id)
            else:
                skill_line_to_prof_spell[skill_line] = supercedes_spell_id

def skill_line_spell_str(skill_line_id):
    result = "[" + str(skill_line_id) + "]=" + str(skill_line_to_prof_spell[skill_line_id]) + ","
    return result

# Assumes spell_id in spell_to_item and spell_id in spell_to_reagents
def reagents_details_str(spell_id):
    reagents = spell_to_reagents[spell_id]
    quantity = spell_to_quantity[spell_id]
    skill_line = spell_to_skill_line[spell_id]
    result = ""
    result = result + "[" + str(spell_id) + "]={reagents={"
    for slot in reagents:
        result = result + "{items={"
        for r in slot[0]:
            result = result + str(r) + ","
        result = result + "},quantity=" + str(slot[1]) + "},"
    result = result + "},quantity=" + str(quantity)
    result = result + ",skillLine=" + str(skill_line) + "},"
    return result

ordered_spells = []
ordered_items = []
ordered_skill_lines = []
skill_lines_seen = {}
item_to_spells = {}
for spell_id in spell_to_reagents:
    if spell_id in spell_to_item and spell_id in spell_to_skill_line:
        ordered_spells.append(spell_id)
        for item_id in spell_to_item[spell_id]:
            if item_id not in item_to_spells:
                ordered_items.append(item_id)
                item_to_spells[item_id] = []
            item_to_spells[item_id].append(spell_id)
        skill_line = spell_to_skill_line[spell_id]
        if skill_line not in skill_lines_seen and skill_line in skill_line_to_prof_spell:
            ordered_skill_lines.append(skill_line)
            skill_lines_seen[skill_line] = True
ordered_spells.sort()
ordered_items.sort()
ordered_skill_lines.sort()

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
print("CraftInfoAnywhere.Data.SkillLinesToSpells={")
for spell_id in ordered_skill_lines:
    print(skill_line_spell_str(spell_id))
print("}")
