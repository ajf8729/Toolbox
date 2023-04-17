switch ((Get-Date -Day 1).DayOfWeek) {
    'Tuesday'   {return 8}
    'Monday'    {return 9}
    'Sunday'    {return 10}
    'Saturday'  {return 11}
    'Friday'    {return 12}
    'Thursday'  {return 13}
    'Wednesday' {return 14}
}
