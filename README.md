# PolyMtl
> Utiliser les données de Polytechnique Montréal

Cette bibliothèque permet d'extraire des données du site de Polytechnique Montréal afin de les réutiliser. Elle sert uniquement à extraire les informations, pas à les formater.

## AVERTISSEMENT

L'AUTEUR NE PEUT ETRE TENU RESPONSABLE EN CAS D'ERREURS DANS CE LOGICIEL. IL EST DU DEVOIR DE L'UTILISATEUR DE VÉRIFIER SUR LES SOURCES OFFICIELLES DE POLYTECHNIQUE MONTRÉAL QUE LES RÉSULTATS FOURNIS SONT VALIDES.

Si vous trouvez des erreurs dans les résultats fournis, merci de bien vouloir prendre le temps de le signaler en ajoutant une « issue » sur la [page GitHub de ce projet](https://github.com/magicienap/poly_mtl/issues).

## Données disponibles

Pour l'instant, il est possible d'extraire les données suivantes :

- Examens
  - Contrôles périodiques
  - Examens finaux

## Réutilisation

Pour l'instant, il est possible d'utiliser les données extraites pour :

- Extraire la liste des contrôles périodiques et/ou des examens finaux pour une liste de cours et de groupes données.

## Installation

Les commandes doivent être saisies dans le terminal et `git` doit y être accessible.

1. Installer Erlang et Elixir*.
2. Cloner ce dépôt : `git clone https://github.com/magicienap/poly_mtl.git`.
3. Se déplacer dans le répertoire du projet : `cd poly_mtl`.
4. Installer les dépendances : `mix deps.get`.
5. Démarrer une session IEx afin de tester le code de cette bibliothèque : `iex -S mix`.

Vous pouvez maintenant essayer les exemples de la section suivante dans IEx.

\* Afin d'utiliser cette bibliothèque, Erlang et Elixir doivent être installés sur votre ordinateur. Pour ce faire, suivez les [instructions sur le site officiel d'Elixir](http://elixir-lang.org/install.html).

## Exemples d'utilisation

Obtenir la liste des contrôles périodiques :
```elixir
PolyMtl.Api.Horaire.Examens.ControlesPeriodiques.obtenir
```

Obtenir la liste des examens finaux :
```elixir
PolyMtl.Api.Horaire.Examens.ExamensFinaux.obtenir
```

Extraire la liste des examens (contrôles périodiques et examens finaux) pour une personne donnée (avec les sigles de cours et les numéros de groupe de théorie) :
```elixir
PolyMtl.Horaires.Examens.extraire_pour({"Tremblay", "Jean"}, [{"MEC1410", 2}, {"MTH1006", 4}, {"MTH1101", 6}])
```

## Contact

Pour tout ce qui touche aux erreurs, bogues, suggestions de fonctionnalités, etc., vous pouvez ajouter une « issue » sur la [page GitHub de ce projet](https://github.com/magicienap/poly_mtl/issues).
