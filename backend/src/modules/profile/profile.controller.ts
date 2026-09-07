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
import { DerivedPreferenceProfileService } from '../memory/derived_preference_profile.service';

/**
 * User profile for personalization (workstream R). Requires a valid JWT.
 * Guards read the user id from the request (JwtStrategy attaches the entity).
 */
@UseGuards(JwtAuthGuard)
@Controller('profile')
export class ProfileController {
  constructor(
    private readonly profileService: ProfileService,
    private readonly derivedService: DerivedPreferenceProfileService,
  ) {}

  @Get('me')
  async me(@Req() req: Request) {
    const view = await this.profileService.getView(userId(req));
    // Phase 2B — attach the computed Derived Preference Profile (additive,
    // backward-compatible field). buildForUserSafe degrades to an empty
    // profile on failure, so /profile/me can never break because of it.
    return {
      ...view,
      derivedPreferences: await this.derivedService.buildForUserSafe(
        userId(req),
        view,
      ),
    };
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
