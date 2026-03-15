# %%
# Load data

import pandas as pd
import numpy  as np


DATASET_FILENAME = 'dataset.csv'

# Read data
df = pd.read_csv(DATASET_FILENAME).set_index('Label')

# Preprocess data
for c in df.columns:
    df[c] = df[c].apply(
        lambda x: np.float64(eval(str(x)))
            if isinstance(x, str) and '/' in str(x)
            else np.float64(x)
    )
df

# %%
# Split DataFrame to logical blocks

import seaborn as sns


QUADRANTS_MULTIPLIERS = {
    1: ( 1,  1,  1),
    # 2: (-1,  1,  1),
    # 3: (-1, -1,  1),
    # 4: ( 1, -1,  1),
    # 5: ( 1,  1, -1),
    # 6: (-1,  1, -1),
    # 7: (-1, -1, -1),
    # 8: ( 1, -1, -1)
}

params_df = df.loc[['a', 'b']]

initial_points_df = df.loc[['v1', 'v2', 'v3', 'v4', 'v5', 'v6']]

points_labels = []
points_data = []

point_number = 1
for quadrant_num, (sign_x, sign_y, sign_z) in QUADRANTS_MULTIPLIERS.items():
    for label in initial_points_df.index:
        x, y, z = initial_points_df.loc[label]

        points_labels.append(f"v{point_number}")
        point_number += 1

        points_data.append((
            sign_x * x,
            sign_y * y,
            sign_z * z
        ))

points_df = pd.DataFrame(
    points_data,
    columns=initial_points_df.columns,
    index=points_labels
)
points_df.describe()

# %%
# Get all surfaces of polyhedron

def get_surface_equasion(p1, p2, p3):
    """Calculates coefficients of surface equasion by three points in R^3.

    :param p1: First surface point
    :param p2: Second surface point
    :param p3: Third surface point
    :return: Tuple with coefficients of surface equasion
    """

    x1, y1, z1 = p1
    x2, y2, z2 = p2
    x3, y3, z3 = p3

    v1 = [x2 - x1, y2 - y1, z2 - z1]
    v2 = [x3 - x1, y3 - y1, z3 - z1]

    n = np.cross(v1, v2)
    A, B, C = n

    D = -(A*x1 + B*y1 + C*z1)

    return A, B, C, D

# Surface settings for each quadrant
SURFACES = {
    1: (1, 2, 3),
    2: (1, 2, 4),
    3: (1, 3, 5),
    4: (2, 3, 6)
}

surfaces_labels = []
surfaces_data = []

surface_number = 1
for i in range(0, len(points_df), len(initial_points_df)):

    for j, value in enumerate(SURFACES.values()):
        surfaces_labels.append(f"s{surface_number}")
        surface_number += 1
        # -1 because indexing of values started from 1
        surfaces_data.append((
            points_data[(i + value[0] - 1)],
            points_data[(i + value[1] - 1)],
            points_data[(i + value[2] - 1)]
        ))

surfaces_df = pd.DataFrame(
    surfaces_data,
    columns=['point1', 'point2', 'point3'],
    index=surfaces_labels
)
surfaces_df.describe()

# %%
# Get all unique points

points_df.drop_duplicates(inplace=True)
points_df.describe()

# %%
# Plot polyhedron

import matplotlib.pyplot as plt

from mpl_toolkits.mplot3d.art3d import Poly3DCollection


fig = plt.figure(figsize=(12, 8))
ax = fig.add_subplot(111, projection='3d')

surfaces_colors = sns.color_palette("Set1", len(SURFACES))

centroids = []

# Plot surfaces
for surface_name, row in surfaces_df.iterrows():

    vertices = np.array([
        row['point1'],
        row['point2'],
        row['point3'],
    ])


    # Add surface labels at centroids
    centroids.append((surface_name, np.mean(vertices, axis=0)))

    ax.add_collection3d(
        Poly3DCollection(
            [vertices],
            alpha=0.7,
            facecolor=surfaces_colors[int(surface_name[1:]) % len(surfaces_colors)],
            edgecolor='black',
            label=surface_name
        )
    )

for surface_name, centroid in centroids:
    ax.text(centroid[0], centroid[1], centroid[2],
        f'  {surface_name}  ',
        fontsize=10, fontweight='bold',
        ha='center', va='center',
        bbox=dict(
            boxstyle='square',
            facecolor='white',
            alpha=0.9,
            edgecolor='black',
            linewidth=2
        ),
        zorder=100
    )

# Plot each point with its label
ax.scatter(
    points_df['x'],
    points_df['y'],
    points_df['z'],
    marker='o',
    s=30,
    color='white',
    linewidths=1,
    edgecolors='black'
)

for idx, row in points_df.iterrows():
    ax.text(
        row['x'],
        row['y'],
        row['z'],
        idx,
        fontsize=8,
        color='black',
        ha='center',
        bbox=dict(boxstyle='round', facecolor='white', alpha=0.9),
        zorder=100,
    )

ax.set_xlabel('X')
ax.set_ylabel('Y')
ax.set_zlabel('Z')
ax.view_init(elev=20, azim=40)
plt.tight_layout()
plt.show()

# %%
# Calculate surface equasion for each surface


def calculate_surface_sign(A, B, C, D, x, y, z):
    """Calculate surface function sign by its coefficients.

    :param A: First coefficient.
    :param B: Second coefficient.
    :param C: Third coefficient.
    :param D: Fourth coefficient.
    :param x: \
    :param y:  }  Point to calculate value in.
    :param z: /
    :return: Sign of function in point: -1, 0 or 1.
    """

    CMP_THRESHOLD = 1e-10

    value = A * x + B * y + C * z + D
    return 0 if abs(value) < CMP_THRESHOLD else (-1 if value < 0 else 1)


surface_equasions = []

for idx, row in surfaces_df.iterrows():
    A, B, C, D = get_surface_equasion(
        row['point1'],
        row['point2'],
        row['point3'],
    )
    surface_equasions.append((A, B, C, D))

# Check that polyhedron is convex
for A, B, C, D in surface_equasions:
    sign = None
    for idx, point in points_df.iterrows():
        new_sign = calculate_surface_sign(
            A, B, C, D,
            point['x'],
            point['y'],
            point['z'],
        )

        if new_sign != 0:
            if sign is not None and new_sign != sign:
                print(f"Point {point} on different space half")
                break
            else:
                sign = new_sign
    else:
        print(f"All points are on same half of space for: ({A})x + ({B})y + ({C})z + ({D})")
        continue
    break
