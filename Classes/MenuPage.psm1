using module .\MenuItem.psm1
class MenuPage {
    [string]$Title
    [System.Collections.Generic.List[MenuItem]]$Items

    MenuPage([string]$title) {
        $this.Title = $title
        $this.Items = [System.Collections.Generic.List[MenuItem]]::new()
    }

    [void]AddItem([MenuItem]$item) {
        $this.Items.Add($item)
    }
}