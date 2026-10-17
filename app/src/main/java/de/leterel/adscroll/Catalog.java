package de.leterel.adscroll;

/** Original fictional demo creatives, not paid impressions or advertiser data. */
public final class Catalog {
    private Catalog() {}
    public static final String[][] ADS = {
        {"PAUSENKAFFEE", "Dein Montag.\nNur besser.", "Ein Schluck Pause. Eine rein erfundene Kaffeemarke.", "#D8FF70", "#183622", "01"},
        {"WOLKENWERK", "Weniger müssen.\nMehr liegen.", "Das Kissen für große Pläne im Liegen. Fiktive Werbung.", "#E1D8FF", "#34244C", "02"},
        {"KNUSPERPOST", "Gute Nachrichten\nsind knusprig.", "Ein imaginärer Snack, direkt aus der Ideenabteilung.", "#FFC989", "#512E19", "03"},
        {"LEERLAUF", "Zeit für\nabsolut nichts.", "Die erfundene Uhr für deine nächste Pause.", "#B8E8F6", "#173945", "04"},
        {"KURZ RAUS", "Dein nächster\nkleiner Umweg.", "Eine fiktive Reiseanzeige. Kein Buchungsangebot.", "#FFBAD0", "#512338", "05"},
        {"MORGEN VIELLEICHT", "Heute passt\nes gerade nicht.", "Imaginäre Alltagsprodukte für echte Aufschieber.", "#E8DFBB", "#3E3822", "06"}
    };
    public static int index(long position) { return (int) Math.floorMod(position, (long) ADS.length); }
    public static long next(long position) { return position == Long.MAX_VALUE ? 0 : Math.max(0, position + 1); }
    public static long previous(long position) { return Math.max(0, position - (position > 0 ? 1 : 0)); }
}
