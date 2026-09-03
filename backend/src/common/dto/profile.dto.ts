import { IsBoolean, IsObject, IsOptional } from 'class-validator';

/**
 * Explicit recommendation preferences a user (or the engine) can persist.
 * Free-form object so new signal types don't require migrations:
 *   { budgetMin, budgetMax, preferredStars, amenities, preferredDestinations }
 */
export class UpdateProfilePreferencesDto {
  @IsOptional()
  @IsObject()
  preferences?: Record<string, any>;

  @IsOptional()
  @IsBoolean()
  personalizationEnabled?: boolean;
}
