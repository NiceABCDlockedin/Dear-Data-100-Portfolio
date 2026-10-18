//Here I am defining all the variable names that I will be using. table represents the variable to store the CSV file I am loading in to Processing.
//The String variables are used to store all data from all the rows in the CSV file and I have defined them here so that they can be global and accessed through the entire program.
//Each variable uses the same name as the column in the CSV file so that it is easy to understand which variable relates to which row in the CSV file.
Table table;
int[] ids;
String[] dates;
String[] types;
String[] touchIns;
String[] statuses;
String[] touchOuts;
String[] reasons;

void setup() {
  //Loads in the CSV file.
  table = loadTable("C:/Users/pnurd/OneDrive - City St George's, University of London/MSci Computer Science (G401)/Year 1/Programming in Java - IN1007/Creative Coding/Portfolio/Dear Data Spreadsheet.csv", "header, csv");
  
  //Checks if the CSV file actually exists.
  if (table == null) {
    println("Error: Could not find or load the CSV file.");
    return;
  }

  //This gets the total number of rows to size the arrays.
  int totalRows = table.getRowCount();
  
  //I am initialising the arrays with the correct size so that all data from the CSV file can be stored in them.
  ids        = new int[totalRows];
  dates      = new String[totalRows];
  types      = new String[totalRows];
  touchIns   = new String[totalRows];
  statuses   = new String[totalRows];
  touchOuts  = new String[totalRows];
  reasons    = new String[totalRows];

  //This for loop will loop through the table and populate the arrays.
  for (int i = 0; i < totalRows; i++) {
    TableRow row = table.getRow(i);
    
    //Stores each column value into the corresponding array at index i.
    ids[i]        = row.getInt("ID"); //Stored as an integer since ID is numerical and increments by 1 for each row.
    dates[i]      = row.getString("Date");
    types[i]      = row.getString("Type"); //Handles both text e.g. "BD" and numbers e.g. "24".
    touchIns[i]   = row.getString("Touch In");
    statuses[i]   = row.getString("Status");
    touchOuts[i]  = row.getString("Touch Out");
    reasons[i]    = row.getString("Reason");
  }
}

