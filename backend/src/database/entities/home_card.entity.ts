import { Entity, PrimaryGeneratedColumn, Column, CreateDateColumn, UpdateDateColumn } from 'typeorm';

@Entity('home_cards')
export class HomeCard {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  sectionId: string;

  @Column()
  cardType: string;

  @Column({ type: 'jsonb' })
  content: Record<string, any>;

  @Column({ type: 'int' })
  order: number;

  @Column({ default: true })
  isVisible: boolean;

  @Column({ nullable: true })
  expiresAt?: Date;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;
}
