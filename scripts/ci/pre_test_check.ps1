# scripts/ci/pre_test_check.ps1
<#
Pre-test gate script.
- Verifica presença de `project.godot`.
- Roda linter se disponível (`gdscript-lint`).
- Executa optional helper lint GDScript `tools/lint.gd` via Godot (se `GODOT_PATH` definido).
- Executa runner de testes unitários (gdUnit4) em modo headless para validar que os testes unitários conseguem iniciar.

Saída:
- exit 0 se todos os checks passarem
- exit 1 caso contrário
#>
param(
    [switch]$SkipGodotCheck
)

function Write-ErrAndExit($msg) {
    Write-Error $msg
    exit 1
}

if (-not (Test-Path project.godot)) {
    Write-ErrAndExit 'project.godot not found in repository root.'
}

Write-Host 'project.godot found.'

# Run gdscript-lint if installed
if (Get-Command gdscript-lint -ErrorAction SilentlyContinue) {
    Write-Host 'Running gdscript-lint...'
    gdscript-lint src || Write-ErrAndExit 'gdscript-lint failed.'
} else {
    Write-Host 'gdscript-lint not found; skipping.'
}

if (-not $SkipGodotCheck) {
    if (-not $env:GODOT_PATH) {
        Write-Host 'GODOT_PATH not set; skipping Godot headless checks. To enable set GODOT_PATH to your godot executable.'
    } else {
        $godot = $env:GODOT_PATH
        Write-Host "Running optional Godot lint helper and unit test runner with $godot"
        if (Test-Path tools/lint.gd) {
            & $godot --headless --script tools/lint.gd || Write-ErrAndExit 'tools/lint.gd failed.'
        } else {
            Write-Host 'No tools/lint.gd found; skipping.'
        }

        # Attempt to run unit tests via gdUnit4 runner if present
        if (Test-Path addons/gdunit4/run_tests.gd) {
            & $godot --headless --script addons/gdunit4/run_tests.gd -- --suite unit || Write-ErrAndExit 'gdUnit4 unit tests failed or could not start.'
        } else {
            Write-Host 'gdUnit4 runner not found at addons/gdunit4/run_tests.gd; skipping unit-run.'
        }
    }
}

Write-Host 'Pre-test checks passed.'
exit 0
