function Invoke-PowerShellNotebook {
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        $NoteBookFullName,
        [Switch]$AsExcel,
        [Switch]$Show
    )

    Process {
        $codeBlocks = Get-NotebookContent $NoteBookFullName -JustCode
        $codeBlockCount = $codeBlocks.Count
        $SheetCount = 0

        for ($idx = 0; $idx -lt $codeBlockCount; $idx++) {
            $targetCode = $codeblocks[$idx].source

            Write-Progress -Activity "Executing PowerShell code block - [$(Get-Date)]" -Status (-join $targetCode) -PercentComplete (($idx + 1) / $codeBlockCount * 100)

            if ($AsExcel) {
                if ($idx -eq 0) {
                    $notebookFileName = Split-Path $NoteBookFullName -Leaf
                    $xlFileName = $notebookFileName -replace ".ipynb", ".xlsx"

                    $xlfile = "{0}\{1}" -f $pwd.Path, $xlFileName
                    Remove-Item $xlfile -ErrorAction SilentlyContinue
                }

                foreach ($dataSet in , @($targetCode | Invoke-Expression)) {
                    if ($dataSet) {
                        $SheetCount++
                        $uniqueName = "Sheet$($SheetCount)"
                        Export-Excel -InputObject $dataSet -Path $xlfile -WorksheetName $uniqueName -AutoSize -TableName $uniqueName
                    }
                }
            }
            else {
                , @($targetCode | Invoke-Expression)
            }
        }

        if ($AsExcel) {
            if ($Show) {
                Invoke-Item $xlfile
            }
            else {
                $xlfile
            }
        }
    }
}