<?php

namespace App\Enums;

enum UserRoleEnum: string
{
    case STUDENT = 'STUDENT';
    case HOD = 'HEAD_OF_DEPARTMENT';
    case AR = 'ASSISTANT_REGISTRAR';
    case SYS_ADMIN = 'SYSTEM_ADMIN';

    public function label(): string
    {
        return match($this) {
            self::STUDENT => 'Student',
            self::HOD => 'Head of Department',
            self::AR => 'Assistant Registrar',
            self::SYS_ADMIN => 'System Administrator',
        };
    }
}
