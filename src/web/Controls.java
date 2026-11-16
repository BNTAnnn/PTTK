package web;
/** Presentation notation used in the textbook class diagrams. */
public final class Controls {
    private Controls() {}
    public static class Text { public final String name; public Text(String name){this.name=name;} }
    public static class Submit { public final String name; public final String label; public Submit(String name,String label){this.name=name;this.label=label;} }
    public static class Link { public final String name; public final String label; public Link(String name,String label){this.name=name;this.label=label;} }
    public static class Panel { public final String name; public Panel(String name){this.name=name;} }
    public static class Table { public final String name; public Table(String name){this.name=name;} }
    public static class Hidden {
        public final String name; public Hidden(String name){this.name=name;}
        public String render(String value){return Html.hidden(name,value);}
    }
}
