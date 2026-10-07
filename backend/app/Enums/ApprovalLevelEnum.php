<?php

namespace App\Enums;

enum ApprovalLevelEnum: string
{
    case ADVISER = 'ADVISER';
    case HOD = 'HOD';
    case DEAN = 'DEAN';
    case FACULTY_AR = 'FACULTY_AR';
}
