class MenuItem {
    [string]$Label
    [string]$Action
    [string]$SubMenu
    [string]$HotKey

    MenuItem([string]$label, [string]$action, [string]$submenu, [string]$hotkey) {
        $this.Label = $label
        $this.Action = $action
        $this.SubMenu = $submenu
        $this.HotKey = $hotkey
    }
}