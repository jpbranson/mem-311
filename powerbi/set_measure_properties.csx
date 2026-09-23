// Tabular Editor (2.x or 3.x) C# script: applies format strings and display folders to the measures
// created from measures.dax. Connect Tabular Editor to the open Power BI Desktop model
// (External tools > Tabular Editor), paste into the C# Script tab, run, then Save (Ctrl+S).

var props = new Dictionary<string, string[]> {
    // name                                             format string        display folder
    { "Data Through Date",                     new[] { "mmm d, yyyy",        "0 Meta" } },
    { "Data Through Label",                    new[] { "",                   "0 Meta" } },
    { "Requests Opened",                       new[] { "#,0",                "1 Responsiveness" } },
    { "Requests Closed",                       new[] { "#,0",                "1 Responsiveness" } },
    { "Net Change (Opened - Closed)",          new[] { "+#,0;-#,0;0",        "1 Responsiveness" } },
    { "Median Resolution (days)",              new[] { "#,0.0",              "1 Responsiveness" } },
    { "P90 Resolution (days)",                 new[] { "#,0.0",              "1 Responsiveness" } },
    { "% Resolved Within 7 Days",              new[] { "0.0%",               "1 Responsiveness" } },
    { "% Resolved Within 30 Days",             new[] { "0.0%",               "1 Responsiveness" } },
    { "Backlog Snapshot Date",                 new[] { "mmm d, yyyy",        "2 Backlog" } },
    { "Open Requests (Backlog)",               new[] { "#,0",                "2 Backlog" } },
    { "Backlog Over 30 Days",                  new[] { "#,0",                "2 Backlog" } },
    { "Backlog Over 90 Days",                  new[] { "#,0",                "2 Backlog" } },
    { "Backlog Over 180 Days",                 new[] { "#,0",                "2 Backlog" } },
    { "% Backlog Over 30 Days",                new[] { "0.0%",               "2 Backlog" } },
    { "% Backlog Over 90 Days",                new[] { "0.0%",               "2 Backlog" } },
    { "Median Backlog Age (days)",             new[] { "#,0",                "2 Backlog" } },
    { "P90 Backlog Age (days)",                new[] { "#,0",                "2 Backlog" } },
    { "Open Requests by Age Band",             new[] { "#,0",                "2 Backlog" } },
    { "Current Backlog",                       new[] { "#,0",                "2 Backlog" } },
    { "Backlog YoY Change %",                  new[] { "+0.0%;-0.0%;0.0%",   "2 Backlog" } },
    { "Backlog Over 90 Days YoY Change %",     new[] { "+0.0%;-0.0%;0.0%",   "2 Backlog" } },
    { "Recurrence Rate 30d",                   new[] { "0.0%",               "3 Durability" } },
    { "Recurrence Rate 90d",                   new[] { "0.0%",               "3 Durability" } },
    { "Recurrence Rate 180d",                  new[] { "0.0%",               "3 Durability" } },
    { "Recurrence Originals (90d)",            new[] { "#,0",                "3 Durability" } },
    { "Recurred Within 90d",                   new[] { "#,0",                "3 Durability" } },
    { "Median Days to Recurrence",             new[] { "#,0.0",              "3 Durability" } },
    { "Recurrence Relationships",              new[] { "#,0",                "3 Durability" } },
    { "Speed vs Durability",                   new[] { "",                   "3 Durability" } },
    { "Sensitivity Recurrence Rate",           new[] { "0.0%",               "3 Durability" } },
    { "Headline Recurrence Rate",              new[] { "0.0%",               "3 Durability" } },
    { "Persistent Locations",                  new[] { "#,0",                "4 Persistent Locations" } },
    { "Chronic Locations",                     new[] { "#,0",                "4 Persistent Locations" } },
    { "Locations With Repeat Requests",        new[] { "#,0",                "4 Persistent Locations" } },
    { "Recurrence Cycles",                     new[] { "#,0",                "4 Persistent Locations" } },
    { "% of Recurrence Cycles at Persistent Locations", new[] { "0.0%",      "4 Persistent Locations" } },
    { "Unresolved at Location",                new[] { "#,0",                "4 Persistent Locations" } },
};

var missing = new List<string>();
foreach (var kv in props) {
    var m = Model.AllMeasures.FirstOrDefault(x => x.Name == kv.Key);
    if (m == null) { missing.Add(kv.Key); continue; }
    if (kv.Value[0] != "") m.FormatString = kv.Value[0];
    m.DisplayFolder = kv.Value[1];
}
if (missing.Count > 0) Info("Not found: " + string.Join(", ", missing));
else Info("Applied properties to " + props.Count + " measures.");
