//Here I am defining all the variable names that I will be using. table represents the variable to store the CSV file I am loading in to Processing.
//The String variables are used to store all data from all the rows in the CSV file and I have defined them here so that they can be global and accessed through the entire program.
//Each variable uses the same name as the column in the CSV file so that it is easy to understand which variable relates to which row in the CSV file.
//I am using LocalDate and LocalTime as well as the formatter to ensure my data for time and date is stored as such and not as a String.
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import processing.sound.*;

Table table;
int[] ids;
LocalDate[] dates;
String[] types;
LocalTime[] touchIns;
String[] statuses;
LocalTime[] touchOuts;
String[] reasons;
SoundFile music;
//This will hold all the values passed back from the TransportMethod class.
TransportMethod[] methods;


void setup() {
  size(1000,1000);
  music = new SoundFile(this, "Internal Needs.mp3");
  music.loop();
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
  dates      = new LocalDate[totalRows];
  types      = new String[totalRows];
  touchIns   = new LocalTime[totalRows];
  statuses   = new String[totalRows];
  touchOuts  = new LocalTime[totalRows];
  reasons    = new String[totalRows];
  
  DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd/MM/yyyy");
  DateTimeFormatter timeFormatter = DateTimeFormatter.ofPattern("HH:mm");

  //This for loop will loop through the table and populate the arrays.
  for (int i = 0; i < totalRows; i++) {
    TableRow row = table.getRow(i);

    //Stores each column value into the corresponding array at index i.
    ids[i]        = row.getInt("ID"); //Stored as an integer since ID is numerical and increments by 1 for each row.
    types[i]      = row.getString("Type"); //Handles both text e.g. "BD" and numbers e.g. "24".
    statuses[i]   = row.getString("Status");
    reasons[i]    = row.getString("Reason");
    
    //Safely parses Date ensuring no N/A values can be passed.
    String dateStr = row.getString("Date");
    if (dateStr != null && !dateStr.trim().isEmpty()) {
      dates[i] = LocalDate.parse(dateStr, dateFormatter);
    } else {
      dates[i] = null;
    }

    //Safely parses Touch In as it handles N/A correctly.
    String touchInStr = row.getString("Touch In");
    if (touchInStr != null && !touchInStr.trim().isEmpty() && !touchInStr.equals("N/A")) {
      touchIns[i] = LocalTime.parse(touchInStr, timeFormatter);
    } else {
      touchIns[i] = null;
    }

    //Safely parses Touch Out as it handles N/A as buses dont have a touch out time.
    String touchOutStr = row.getString("Touch Out");
    if (touchOutStr != null && !touchOutStr.trim().isEmpty() && !touchOutStr.equals("N/A")) {
      touchOuts[i] = LocalTime.parse(touchOutStr, timeFormatter);
    } else {
      touchOuts[i] = null;
    }
  }
  
  //Find the earliest and latest dates to use as the boundaries for mapping for the y position in the class TransportMethod.
  //Find the first valid date to initialize minDate and maxDate.
  LocalDate minDate = null;
  LocalDate maxDate = null;
  for (LocalDate d : dates) {
    if (d != null) {
      if (minDate == null || d.isBefore(minDate)) minDate = d;
      if (maxDate == null || d.isAfter(maxDate)) maxDate = d;
    }
  }
  
  //Fallback just in case every single date was null.
  if (minDate == null) {
    minDate = LocalDate.now();
    maxDate = LocalDate.now();
  }
  
  //Initialise the methods array container before filling it.
  methods = new TransportMethod[totalRows];
  
  //Initalise each TransportMethod object by passing in the values.
  for (int i = 0; i < totalRows; i++) {
    methods[i] = new TransportMethod(
      dates[i],
      touchIns[i],
      types[i],
      reasons[i],
      statuses[i],
      minDate,
      maxDate,
      100,         //Top margin for Y position
      height - 100 //Bottom margin for Y position
    );
  }
}

void draw() {
  background(255);
  stroke(0);
  strokeWeight(2);
  line(10, 0, 10, height-10);
  line(10, height-10, width - 10, height-10);
  noStroke();

  for (TransportMethod m : methods) {
    m.draw();
  }
}

//Defining the class that I will be using to create a ball to represent each different transport method.
class TransportMethod {
  PVector position; //Position of the ball
  float radius;     //Radius of the ball
  color colour;     //Colour to be used on the ball
  float yPos;
  
  //The constructor method takes in the travel details used to position and colour each ball.
  TransportMethod(LocalDate date, LocalTime touchIn, String type, String reason, String status, LocalDate minDate, LocalDate maxDate, float minY, float maxY) {
    radius = 15;
    
    //Making it so that the x position is mapped to the time which will give the total number of seconds using getHour(), getMinute() and the range will be between 0 and 86400.
    float x = 50;
    if (touchIn != null) {
      int totalSeconds = (touchIn.getHour() * 3600) + (touchIn.getMinute() * 60) + touchIn.getSecond();
      x = map(totalSeconds, 0, 86400, 50, width - 50);
    }
    
    //I am using a long variable type to define the y position to count the number of days since the Unix epoch and then minus these to find the y position, else if they are the same date add them both and divide by 2.
    yPos = (minY + maxY) / 2;
    if (date != null && minDate != null && maxDate != null) {
      long minDay = minDate.toEpochDay();
      long maxDay = maxDate.toEpochDay();
      if (minDay != maxDay) {
        yPos = map(date.toEpochDay(), minDay, maxDay, minY, maxY);
      }
    }
    
    //Creating a new PVector for each new ball created.
    position = new PVector(x, yPos);
    
    if (type == null) {
      type = "";
    }
    //The transport type sets the base colour and the reason adds a tint and late journeys are darkened whereas on time journeys are not.
    colour = adjustColour(getColourforType(type), reason, status);
  }
  
  //From below this constructor are the methods I am using the find the colour to be associated based on the type of transportation used as well as to draw the ball and these will be associated with any instance of a TransportMethod object.
  //This is the method to get the ball colour and I am using switch to be a decision maker based on the different methods possibly used and return a color or return white if not any of those.
  color getColourforType(String type) {
    switch (type) {
      case "EL": return color(112,48,160);
      case "BD": return color(174,30,30);
      case "24": return color(255,0,0);
      case "SL": return color(255,51,0);
      case "LU": return color(15,0,204);
      case "NR": return color(255,255,0);
      case "LO": return color(255,192,0);
      case "TR": return color(146,208,80);
      case "DL": return color(0,176,240);
      case "BN": return color(0,32,96);
      default: return color(255,255,255);
    }
  }
  //This is the adjustColour method, and this takes in the original colour that was returned from getColourforType() and then takes in the reason and status as Strings and darkens the colour if the journey was Late and adds a tint based on the reason for travel.
  color adjustColour(color baseColour, String reason, String status) {
    color adjustedColour = baseColour;

    if (reason != null) {
      if (reason.trim().equalsIgnoreCase("University")) {
        //lerpColor() is used to blend the base colour with a new colour
        adjustedColour = lerpColor(adjustedColour, color(100, 160, 255), 0.12);
      } else if (reason.trim().equalsIgnoreCase("Leisure")) {
        adjustedColour = lerpColor(adjustedColour, color(255, 190, 100), 0.12);
      }
    }

    if (status != null && status.trim().equalsIgnoreCase("Late")) {
      adjustedColour = color(
        red(adjustedColour) * 0.8,
        green(adjustedColour) * 0.8,
        blue(adjustedColour) * 0.8
      );
    }

    return adjustedColour;
  }
  
  //This is the draw method which will draw the ball at the current position.
  void draw() {
      noStroke();
      fill(colour);
      ellipse(position.x, position.y, radius * 2, radius * 2);
  }
}
