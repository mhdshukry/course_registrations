<?php

namespace App\Enums;

enum CourseTypeEnum: string
{
    case COMPULSORY = 'COMPULSORY';
    case ELECTIVE = 'ELECTIVE';
    case OPTIONAL = 'OPTIONAL';
    case REPEAT = 'REPEAT';
    case NON_CREDIT = 'NON_CREDIT';
    case AUDIT = 'AUDIT';
}
