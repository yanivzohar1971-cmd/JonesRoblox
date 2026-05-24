"""
Jones Roblox — test Blender asset script.
Creates a low-poly apple-like mesh and exports GLB for Studio import testing.

Run headless from repo root:
  blender --background --python Assets/Blender/create_test_asset.py
"""

from pathlib import Path

import bpy

SCRIPT_DIR = Path(__file__).resolve().parent
EXPORT_DIR = SCRIPT_DIR / "exports"
EXPORT_PATH = EXPORT_DIR / "apple_test.glb"

APPLE_COLOR = (0.72, 0.12, 0.10, 1.0)
STEM_COLOR = (0.25, 0.45, 0.18, 1.0)


def clear_scene() -> None:
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

    for block in bpy.data.meshes:
        if block.users == 0:
            bpy.data.meshes.remove(block)
    for block in bpy.data.materials:
        if block.users == 0:
            bpy.data.materials.remove(block)


def make_material(name: str, rgba: tuple[float, float, float, float]) -> bpy.types.Material:
    material = bpy.data.materials.new(name=name)
    material.use_nodes = True
    nodes = material.node_tree.nodes
    principled = nodes.get("Principled BSDF")
    if principled:
        principled.inputs["Base Color"].default_value = rgba
        principled.inputs["Roughness"].default_value = 0.55
    return material


def create_apple_body(material: bpy.types.Material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_uv_sphere_add(segments=16, ring_count=10, radius=0.5, location=(0, 0, 0.5))
    apple = bpy.context.active_object
    apple.name = "AppleBody"
    apple.scale = (0.9, 0.9, 1.05)
    apple.data.materials.append(material)
    return apple


def create_stem(material: bpy.types.Material) -> bpy.types.Object:
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.04, depth=0.12, location=(0, 0, 1.08))
    stem = bpy.context.active_object
    stem.name = "AppleStem"
    stem.data.materials.append(material)
    return stem


def export_glb(path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(
        filepath=str(path),
        export_format="GLB",
        use_selection=False,
        export_apply=True,
        export_materials="EXPORT",
    )


def main() -> None:
    clear_scene()
    apple_material = make_material("AppleRed", APPLE_COLOR)
    stem_material = make_material("AppleStem", STEM_COLOR)
    create_apple_body(apple_material)
    create_stem(stem_material)
    export_glb(EXPORT_PATH)
    print(f"Exported test asset: {EXPORT_PATH}")


if __name__ == "__main__":
    main()
