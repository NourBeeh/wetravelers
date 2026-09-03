import {
  Body,
  Controller,
  Get,
  Patch,
  Req,
  UseGuards,
} from '@nestjs/common';
import { Request } from 'express';
import { JwtAuthGuard } from '../auth/jwt-auth.guard';
import { UpdateProfilePreferencesDto } from '../../common/dto/profile.dto';
import { ProfileService } from './profile.service';

/**
 * User profile for personalization (workstream R). Requires a valid JWT.
 * Guards read the user id from the request (JwtStrategy attaches the entity).
 */
@UseGuards(JwtAuthGuard)
@Controller('profile')
export class ProfileController {
  constructor(private readonly profileService: ProfileService) {}

  @Get('me')
  me(@Req() req: Request) {
    return this.profileService.getView(userId(req));
  }

  @Patch('me')
  update(@Req() req: Request, @Body() dto: UpdateProfilePreferencesDto) {
    return this.profileService.updatePreferences(userId(req), dto);
  }
}

/** Passport's Express.User is an empty interface; the JWT strategy attaches
 * the full user entity, so the id is safely readable here. */
function userId(req: Request): string {
  const user = req.user as { id?: string } | undefined;
  if (!user?.id) throw new Error('Authenticated request missing user id.');
  return user.id;
}
