# Chemin du dossier contenant les modèles 3D en format GLTF
$modeleGLTFDossier = "C:\Users\alex\Desktop\script\3dModelExtractor\models"

# Chemin de sortie du dossier pour les modèles 3D en format GLTF
$modeleGLTFDossierFinal = "C:\Users\alex\Desktop\script\3dModelExtractor\extract"

# Chemin vers le fichier Blender exécutable
$blenderExecutable = "C:\Program Files\Blender Foundation\Blender 4.0\blender.exe"

# Parcourir chaque fichier .gltf dans le dossier
Get-ChildItem -Path $modeleGLTFDossier -Filter *.gltf | ForEach-Object {
    $modeleGLTF = $_.FullName
    $modeleName = $_.BaseName
    $modeleGLTFOut = Join-Path -Path $modeleGLTFDossierFinal -ChildPath ("{0}\{0}.gltf" -f $modeleName)

    # Créer le dossier de sortie si nécessaire
    $modeleGLTFDossierOut = Split-Path -Path $modeleGLTFOut -Parent
    if (!(Test-Path -Path $modeleGLTFDossierOut)) {
        New-Item -ItemType Directory -Force -Path $modeleGLTFDossierOut
    }

    # Création d'un script Python temporaire
    $scriptPython = @"
import bpy
import os
bpy.ops.object.select_all(action='SELECT')
bpy.ops.object.delete()
bpy.ops.wm.read_factory_settings()

bpy.ops.import_scene.gltf(filepath=r'${modeleGLTF}')
bpy.ops.object.select_all(action='SELECT')
bpy.ops.transform.rotate(value=1.5708, orient_axis='X')

bpy.ops.object.transform_apply(location=False, rotation=True, scale=False)
bpy.ops.export_scene.gltf(filepath=r'${modeleGLTFOut}', export_format='GLTF_SEPARATE')
"@

    # Écriture du script Python dans un fichier temporaire
    $scriptFile = New-TemporaryFile | Rename-Item -NewName { $_ -replace '\.tmp$', '.py' } -PassThru
    $scriptPython | Out-File -FilePath $scriptFile.FullName -Encoding ASCII

    # Lancer Blender en mode arrière-plan et exécuter le script Python
    Start-Process -FilePath $blenderExecutable -ArgumentList "--background", "--python", $scriptFile.FullName -NoNewWindow -Wait

    # Suppression du fichier script Python temporaire
    Remove-Item -Path $scriptFile.FullName
}
