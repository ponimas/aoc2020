import algorithm
import sequtils
import sets
import streams
import strutils
import sugar
import tables

import unpack
import memo

from strformat import fmt

proc findPossibleAllergens(input: seq[(HashSet[string], HashSet[string])]): Table[string, HashSet[string]] {.memoized.} =
  var tbl: Table[string, HashSet[string]]
  for (ingredients, allergens) in input:
    for allergen in allergens:
      tbl[allergen]= tbl.getOrDefault(allergen, ingredients) * ingredients
  return tbl
    

proc first(input: seq[(HashSet[string], HashSet[string])]): int =
  var
    possibleAllergens = findPossibleAllergens(input)
    safeIngredients = collect(initHashSet):
      for (ingredients, _) in input:
        for ingredient in ingredients:
          {ingredient}

  for allergens in possibleAllergens.values():
    for allergen in allergens:
      safeIngredients.excl(allergen)

  return input.foldl(a + len(intersection(b[0], safeIngredients)), 0)


proc second(input: seq[(HashSet[string], HashSet[string])]): string =
  var
    possibleAllergens = findPossibleAllergens(input)
    unsafeIngredients = collect(initHashSet):
      for ingredients in possibleAllergens.values():
        for ingredient in ingredients:
          {ingredient}

  while len(unsafeIngredients) > 0:
    for (allergen, _) in toSeq(possibleAllergens.pairs()).sortedByIt(len(it[1])):
      let ingredients = possibleAllergens[allergen]
      if len(ingredients) == 1:
        let ingredient = toSeq(ingredients.items())[0]
        unsafeIngredients.excl(ingredient)
        for (a, products) in possibleAllergens.mpairs():
          if a != allergen:
            products.excl(ingredient)

  var allergenList = collect(newSeq):
    for (_, products) in sorted(toSeq(possibleAllergens.pairs())):
      toSeq(products)[0]
  return allergenList.join(",")
  
        
proc solution*(stream: FileStream) =
  let input = collect(newSeq):
    for l in stream.lines():
      if l == "":
        continue
      [left, right] <- l.split(" (contains ")
      let
        ingredients = toHashSet(left.splitWhitespace())
        allergens = toHashSet(right[0 .. ^2].split(", "))
      (ingredients, allergens)

  let f = first(input)
  echo fmt"first {f}"

  let s = second(input)
  echo fmt"second {s}"

