<?php

namespace App\Enums;

enum UserRoleEnum: string
{
    case STUDENT = 'STUDENT';
    case ADVISER = 'ACADEMIC_ADVISER';
    case LECTURER = 'LECTURER';
    case HOD = 'HEAD_OF_DEPARTMENT';
    case COORDINATOR = 'FACULTY_COORDINATOR';
    case AR = 'ASSISTANT_REGISTRAR';
    case CENTRAL_ADMIN = 'CENTRAL_ADMIN';
    case SYS_ADMIN = 'SYSTEM_ADMIN';

    public function label(): string
    {
        return match($this) {
            self::STUDENT => 'Student',
            self::ADVISER => 'Academic Adviser',
            self::LECTURER => 'Lecturer',
            self::HOD => 'Head of Department',
            self::COORDINATOR => 'Faculty Coordinator',
            self::AR => 'Assistant Registrar',
            self::CENTRAL_ADMIN => 'Central Administrator',
            self::SYS_ADMIN => 'System Administrator',
        };
    }
}
