<#
Created By: Alan Newingham
Name: WPFPasswordMangler
Date: 02/18/2021

Create a WPF that generates passwords so I stop using https://passwordsgenerator.net/
#>

Add-Type -AssemblyName PresentationCore, PresentationFramework
$Xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        Title="MainWindow"
        Height="278"
        Width="401"
        WindowStyle="None"
        ResizeMode="CanResize"
        AllowsTransparency="True"
        WindowStartupLocation="CenterScreen"
        Background="#FF5D5D5D"
        Foreground="Azure"
        FontFamily="Century Gothic"
        FontSize="14"
        Opacity="1" >
    <Window.Resources>
        <Style x:Key="MyButton" TargetType="Button">
            <Setter Property="OverridesDefaultStyle" Value="True" />
            <Setter Property="Cursor" Value="Hand" />
            <Setter Property="Template">
                <Setter.Value>
                    <ControlTemplate TargetType="Button">
                        <Border Name="border" BorderThickness="1" BorderBrush="Azure" Background="{TemplateBinding Background}">
                            <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center" />
                        </Border>
                        <ControlTemplate.Triggers>
                            <Trigger Property="IsMouseOver" Value="True">
                                <Setter Property="Opacity" Value="0.8" />
                            </Trigger>
                        </ControlTemplate.Triggers>
                    </ControlTemplate>
                </Setter.Value>
            </Setter>
        </Style>
        <Style TargetType="TextBox">
            <Setter Property="Background" Value="Gray"  />
        </Style>
    </Window.Resources>
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition/>
        </Grid.ColumnDefinitions>
        <Grid Height="30" HorizontalAlignment="Stretch" VerticalAlignment="Top" Background="#FF474747">
            <StackPanel Orientation="Horizontal">
                <Button Name="close_btn" Foreground="Azure" Height="20" Width="20" Background="Transparent" Content="X" FontSize="14" Margin="10,0,0,0" FontWeight="Bold" Style="{StaticResource MyButton}"/>
                <Button Name="minimize_btn" Foreground="Azure" Height="20" Width="20" Background="Transparent" Content="-" FontSize="14" Margin="2 0 0 0" FontWeight="Bold" Style="{StaticResource MyButton}"/>
                <TextBlock Text="Aimee's Password Mangler" Foreground="Azure" VerticalAlignment="Center" Margin="150,6" />
            </StackPanel>
        </Grid>
        <TextBox Name="text_bx" HorizontalAlignment="Left" Height="23" Margin="130,37,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Width="185"/>
        <TextBlock Foreground="Azure" HorizontalAlignment="Left" Margin="7,40,0,0" TextWrapping="Wrap" VerticalAlignment="Top" Text="Current Password:"/>
        <TextBox ScrollViewer.VerticalScrollBarVisibility="Auto" Name="text_box" FontFamily="Consolas" HorizontalAlignment="Left" Margin="6,62,0,26" TextWrapping="Wrap" Width="389"/>
        <Button Name="btn_gen" Background="Transparent" Foreground="Azure" Content="MANGLE" HorizontalAlignment="Left" Margin="317,39,0,0" VerticalAlignment="Top" Width="75" Style="{StaticResource MyButton}"/>
        <TextBlock HorizontalAlignment="Left" Margin="141,256,0,0"  Foreground="#FF122BCD" TextWrapping="Wrap" VerticalAlignment="Top" Text="By Alan Newingham" FontFamily="Source Serif Pro Semibold"/>
    </Grid>
</Window>


"@


#-------------------------------------------------------------#
#                      Window Function                        #
#-------------------------------------------------------------#
$Window = [Windows.Markup.XamlReader]::Parse($Xaml)

[xml]$xml = $Xaml

$xml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $Window.FindName($_.Name) }

#-------------------------------------------------------------#
#                  Define Window Move                         #
#-------------------------------------------------------------#

#Click and Drag WPF window without title bar (ChromeTab or whatever it is called)
$Window.Add_MouseLeftButtonDown({
    $Window.DragMove()
})

#-------------------------------------------------------------#
#                   Function Hide Console Window              #
#-------------------------------------------------------------#
function Show-Console
{
    param ([Switch]$Show,[Switch]$Hide)
    if (-not ("Console.Window" -as [type])) { 

        Add-Type -Name Window -Namespace Console -MemberDefinition '
        [DllImport("Kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
        '
    }

    if ($Show)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()

        # Hide = 0,
        # ShowNormal = 1,
        # ShowMinimized = 2,
        # ShowMaximized = 3,
        # Maximize = 3,
        # ShowNormalNoActivate = 4,
        # Show = 5,
        # Minimize = 6,
        # ShowMinNoActivate = 7,
        # ShowNoActivate = 8,
        # Restore = 9,
        # ShowDefault = 10,
        # ForceMinimized = 11

        $null = [Console.Window]::ShowWindow($consolePtr, 5)
    }

    if ($Hide)
    {
        $consolePtr = [Console.Window]::GetConsoleWindow()
        #0 hide
        $null = [Console.Window]::ShowWindow($consolePtr, 0)
    }
}

Show-Console -Hide


#-------------------------------------------------------------#
#                      Define Buttons                         #
#-------------------------------------------------------------#

#Custom Close Button
$close_btn.add_Click({
    $Window.Close();
})
#Custom Minimize Button
$minimize_btn.Add_Click({
    $Window.WindowState = 'Minimized'
})


#Custom Minimize Button
$btn_gen.Add_Click({

   $str = $text_bx.Text
   $arr = $str.ToCharArray()
   $XXX = $arr | Sort-Object {Get-Random}
   $XXX = [system.String]::Join("", $XXX)
            $text_box.Text += "Aimee has mangled your password into:"
            $text_box.Text += "`n"
            $text_box.Text += [string]$XXX
            $text_box.Text += "`n"
})

#-------------------------------------------------------------#
#                   Define Conditionals                       #
#-------------------------------------------------------------#

#Show Window, without this, the script will never initialize the OSD of the WPF elements.
$Window.ShowDialog()
