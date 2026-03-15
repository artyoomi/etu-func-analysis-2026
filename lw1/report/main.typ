/*
Template according to: https://se.moevm.info/doku.php/courses:reportrules

Latex reference from one cool guy:
https://github.com/JAkutenshi/eltechLaTeXTemplates/blob/master/LabReports/tex/title.tex
*/


// Page setup
#set page(
  width: 210mm,
  height: 297mm,
  margin: (top: 20mm, bottom: 20mm, left: 30mm, right: 15mm)
)

// General text setup
#set text(
  size: 14pt,
  lang: "ru"
)

// Paragraph setup
#set par(
  leading: 1.5em,
  first-line-indent: 1.25cm,
  justify: true
)

// To provide numeration like 1, 1.1, 1.1.1 and so on
#set enum(full: true)

// Setup level 1 header
#show heading.where(level: 1): it => [
  #set text(size: 14pt, weight: "bold")
  #set par(first-line-indent: 0pt, leading: 1.5em)
  #set align(center)
  #upper(it.body)
]

// Setup level 2 header
#show heading.where(level: 2): it => [
  #set text(size: 14pt, weight: "bold")
  #set par(first-line-indent: 1.25cm, leading: 1.5em, justify: true)
  #it.body
]

// Setup level 3 header
#show heading.where(level: 3): it => [
  #set text(size: 13pt, weight: "bold")
  #set par(first-line-indent: 1.25cm, leading: 1.5em, justify: true)
  #it.body
]

// Setup table captions
#show figure.where(kind: table): fig => {
  align(left)[
    #fig.caption
    #fig.body
  ]
}

// Long "-" between numering and caption in all figures
#show figure: set figure.caption(separator: [ ---])

// Allow all figures containing tables to break across pages
#show figure.where(kind: table): set block(breakable: true)

// Force all raw blocks to have 1em indent between lines
#show raw.where(block: true): set par(leading: 1em)
// Force all raw blocks to have left alignment
// #show raw.where(block: true): set align(left)

// Enable formula numbering
#set math.equation(numbering: "(1)")

// First page setup
#align(center)[
  #set text(weight: "semibold")

  #set par(leading: 1em)

  МИНОБРНАУКИ РОССИИ \
  САНКТ-ПЕТЕРБУРГСКИЙ ГОСУДАРСТВЕННЫЙ \
  ЭЛЕКТРОТЕХНИЧЕСКИЙ УНИВЕРСИТЕТ \
  «ЛЭТИ» ИМ. В.И. УЛЬЯНОВА (ЛЕНИНА) \
  Кафедра МО ЭВМ

  #v(54mm)

  ОТЧЕТ \
  по домашней работе №1 \
  по дисциплине "Элементы функционального анализа" \


  #v(54mm)

  #table(
    columns: (33%, 33%, 33%),
    inset: 10pt,
    align: horizon,
    stroke: none,
    "Студент гр. 3381",
    "",
    table.hline(start: 1 , end: 2),
    "Иванов А. А.",
    "Преподаватель",
    "",
    table.hline(start: 1 , end: 2),
    "Коточигов А. М."
  )

  #set align(bottom)
  Санкт-Петербург \
  #datetime.today().year()
]
#pagebreak()

// Start numbering here to skip first page numering
#set page(
  numbering: "1"
)

// To make indent before first header

\
== Задание

+ Построить по набору точек из первой квадранты кусок многогранника;
+ Построить остальные части многогранника, считая, что остальные части симметричны относительно соответствующих координат;
+ Проверить, что полученный многогранник является выпуклым.

\
== Выполнение работы

Для визуализации данных и вычислений используется язык программирования Python и его библиотеки для визуализации данных и вычислений: NumPy, Pandas, seaborn, matplotlib.

=== Отображение точек на остальные квадранты

При переходе между квадрантами знаки координат точек меняются по определённому закону. Соответствующие множители представлены в @quadrants.

#figure(
  caption: [
    Множители при переменных в каждой квадранте
  ],
  ```python
  quadrants = {
    1: ( 1,  1,  1),
    2: (-1,  1,  1),
    3: (-1, -1,  1),
    4: ( 1, -1,  1),
    5: ( 1,  1, -1),
    6: (-1,  1, -1),
    7: (-1, -1, -1),
    8: ( 1, -1, -1)
  }
  ```
) <quadrants>

После отображения точек из первой квадранты в остальные квадранты получены точки, представленны в @all_points.

#let all_points = csv("csv/all_points.csv")
#figure(
  caption: [
    Все вершины многогранника с дубликатами.
  ],
  table(
    align: center,
    columns: (25%, 25%, 25%, 25%),
    ..all_points.flatten()
  ),
) <all_points>

=== Удаление дубликатов из множества точек

Точки после удаления дубликатов представлены на @deduplicated_points.

#let deduplicated_points = csv("csv/deduplicated_points.csv")
#figure(
  caption: [
    Все вершины многогранника без дубликатов.
  ],
  table(
    align: center,
    columns: (25%, 25%, 25%, 25%),
    ..deduplicated_points.flatten()
  ),
) <deduplicated_points>

== Построение граней многогранника

После этого были построены грани многогранника в первой квадранте, а затем отображены на остальные квадранты относительно соответствующих осей.

В @surfaces приведены построенные грани.

#let surfaces = csv("csv/surfaces.csv")
#figure(
  caption: [
    Грани многогранника.
  ],
  table(
    align: center,
    columns: (25%, 25%, 25%, 25%),
    ..surfaces.flatten()
  ),
) <surfaces>

Ниже на @polyhedron_quadrant1 приведена часть многогранника на первой квадранте (остальные части не приведены, так как иначе изображение становится слишком громоздким).

#figure(
  caption: [
    Изображение многогранника в первой квадранте. $s_i$ обозначены грани, а $v_j$ -- точки многогранника.
  ],
  image("images/polyhedron_quadrant1.png"),
) <polyhedron_quadrant1>

=== Проверка многогранника на выпуклость

Пусть $arrow(p_1)$, $arrow(p_2)$, $arrow(p_3)$ -- точки в $RR^3$, для которых строится поверхность. Для получения уравнений поверхностей использовалось свойство нормы к поверхности, которое гласит, что норма $arrow(n) = [(arrow(p_2) - arrow(p_1)) times (arrow(p_3) - arrow(p_1))]$ равна вектору $(A, B, C)$, где $A$, $B$, $C$ --- соответствующие коэффициенты плоскости. $D$ вычисляется из уравнения $A x + B y + C z + D = 0$ подстановкой точки $arrow(p_1)$.

Вычисленные уравнения поверхностей для полученных граней представлены в @surface_equasions.

#figure(
  caption: [
    Уравнения плоскостей $s_1$, $s_2$, $s_3$ и $s_4$.
  ],
  table(
    align: center,
    inset: 8pt,
    columns: (10%, 90%),
    [$s_i$], [$A x + B y + C z + D$],
    $s_1$, $-16 x - 16 y - 24 z + 176$,
    $s_2$, $6 x + 3 y + 4.5 z - 57$,
    $s_3$, $-20 x - 32 y - 24 z + 256$,
    $s_4$, $55/3 x + 40/3 y + 40 z - 680/3$,
  )
) <surface_equasions>

С помощью скрипта проверено, что все точки многогранника либо лежат на этих поверхностях, либо все вместе лежат по одну сторону от многогранника. В силу вышесказанного и симментрии плоскостей в разных квадратнах относительно соответствующих осей, многогранник является выпуклым.

#pagebreak()
= Приложение А \ ИСХОДНЫЙ КОД

#show link: underline
Ссылка: #link("https://github.com/artyoomi/ml-introduction")

