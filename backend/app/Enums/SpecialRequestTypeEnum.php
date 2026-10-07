<?php

namespace App\Enums;

enum SpecialRequestTypeEnum: string
{
    case OVERLOAD = 'OVERLOAD';
    case PREREQUISITE_WAIVER = 'PREREQUISITE_WAIVER';
    case LATE_REGISTRATION = 'LATE_REGISTRATION';
    case TIMETABLE_CLASH = 'TIMETABLE_CLASH';
    case SUBSTITUTION = 'SUBSTITUTION';
}
