import { validate } from 'class-validator';
import { FlightSearchDto } from '../src/common/dto/flight.search.dto';

describe('DTO Validation', () => {
  it('should fail when required fields missing', async () => {
    const dto = new FlightSearchDto();
    const errors = await validate(dto);
    expect(errors.length).toBeGreaterThan(0);
  });
});
